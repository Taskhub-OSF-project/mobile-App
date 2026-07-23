import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../messaging/data/models/messaging_models.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final int conversationId;

  const ChatScreen({super.key, required this.conversationId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  List<MessageResponse> _messages = [];
  bool _isLoading = true;
  String? _error;
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  int? _currentUserId;
  String? _otherUserName;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _currentUserId = ref.read(currentUserProvider)?.id;
    _loadMessages();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted) {
        _loadMessages(silent: true);
      }
    });
  }

  Future<void> _loadMessages({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }
    final result = await ref
        .read(messagingRepositoryProvider)
        .getMessages(widget.conversationId);
    if (result.isSuccess && mounted) {
      final msgs = result.data?.content ?? [];
      msgs.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      // Lấy tên người kia từ tin nhắn đầu tiên không phải của mình
      if (_otherUserName == null) {
        final otherMsg = msgs.firstWhere(
          (m) => m.senderId != _currentUserId,
          orElse: () => msgs.isNotEmpty ? msgs.first : throw Exception(),
        );
        if (otherMsg.senderId != _currentUserId) {
          _otherUserName = otherMsg.senderName;
        }
      }

      bool shouldScroll = false;
      if (silent && _messages.isNotEmpty && msgs.isNotEmpty && msgs.length > _messages.length) {
         if (_scrollController.hasClients &&
             _scrollController.position.maxScrollExtent - _scrollController.position.pixels < 100) {
           shouldScroll = true;
         }
      } else if (!silent) {
         shouldScroll = true;
      }

      setState(() {
        _messages = msgs;
        if (!silent) _isLoading = false;
      });
      // Mark as read
      ref.read(messagingRepositoryProvider).markAsRead(widget.conversationId);

      if (shouldScroll) {
        _scrollToBottom();
      }
    } else if (mounted && !silent) {
      setState(() {
        _error = result.error?.message ?? 'Tải tin nhắn thất bại';
        _isLoading = false;
      });
    }
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    _textController.clear();
    final result = await ref
        .read(messagingRepositoryProvider)
        .sendMessage(widget.conversationId, text);

    if (result.isSuccess && mounted) {
      setState(() {
        _messages.add(result.data!);
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_otherUserName ?? 'Trò chuyện'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child:
                            Text(_error!, style: const TextStyle(color: Colors.red)))
                    : _messages.isEmpty
                        ? const Center(
                            child: Text('Chưa có tin nhắn. Hãy bắt đầu trò chuyện!',
                                style: TextStyle(color: Colors.grey)))
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(16),
                            itemCount: _messages.length,
                            itemBuilder: (context, index) {
                              final msg = _messages[index];
                              final isMe = msg.senderId == _currentUserId;
                              return _MessageBubble(
                                message: msg,
                                isMe: isMe,
                              );
                            },
                          ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Nhập tin nhắn...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: AppTheme.primary,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageResponse message;
  final bool isMe;

  const _MessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? Colors.green.shade600 : Colors.grey.shade600,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.createdAt),
              style: const TextStyle(
                fontSize: 10,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '';
    }
  }
}
