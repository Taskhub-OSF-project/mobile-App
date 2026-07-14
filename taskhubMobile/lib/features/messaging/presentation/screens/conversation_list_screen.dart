import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../messaging/data/models/messaging_models.dart';
import '../../../../shared/widgets/common_widgets.dart';

class ConversationListScreen extends ConsumerStatefulWidget {
  const ConversationListScreen({super.key});

  @override
  ConsumerState<ConversationListScreen> createState() =>
      _ConversationListScreenState();
}

class _ConversationListScreenState
    extends ConsumerState<ConversationListScreen> {
  List<ConversationResponse> _conversations = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final result =
        await ref.read(messagingRepositoryProvider).getConversations();
    if (result.isSuccess && mounted) {
      setState(() {
        _conversations = result.data?.content ?? [];
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() {
        _error = result.error?.message ?? 'Tải danh sách tin nhắn thất bại';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tin nhắn'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? ErrorDisplay(
                  message: _error!, onRetry: _loadConversations)
              : _conversations.isEmpty
                  ? const EmptyState(
                      icon: Icons.chat_bubble_outline,
                      title: 'Chưa có tin nhắn',
                      subtitle: 'Bắt đầu cuộc trò chuyện từ một công việc',
                    )
                  : RefreshIndicator(
                      onRefresh: _loadConversations,
                      child: ListView.builder(
                        itemCount: _conversations.length,
                        itemBuilder: (context, index) {
                          final conv = _conversations[index];
                          return _ConversationTile(conversation: conv);
                        },
                      ),
                    ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final ConversationResponse conversation;

  const _ConversationTile({required this.conversation});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => context.push('/messages/${conversation.id}'),
      leading: CircleAvatar(
        backgroundColor: AppTheme.primary.withOpacity(0.1),
        child: Text(
          (conversation.otherUserName != null && conversation.otherUserName!.isNotEmpty)
              ? conversation.otherUserName![0].toUpperCase()
              : 'U',
          style: const TextStyle(
              color: AppTheme.primary, fontWeight: FontWeight.bold),
        ),
      ),
      title: Text(
        conversation.otherUserName ?? 'Không rõ',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (conversation.taskTitle != null)
            Text(
              'Công việc: ${conversation.taskTitle}',
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          if (conversation.lastMessagePreview != null)
            Text(
              conversation.lastMessagePreview!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: conversation.unreadCount > 0
                      ? FontWeight.w600
                      : FontWeight.normal),
            ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (conversation.unreadCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${conversation.unreadCount}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const SizedBox(height: 4),
          if (conversation.lastMessageAt != null)
            Text(
              _formatTime(conversation.lastMessageAt!),
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
        ],
      ),
    );
  }

  String _formatTime(String iso) {
    try {
      final dt = DateTime.parse(iso);
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes}m';
      if (diff.inHours < 24) return '${diff.inHours}h';
      if (diff.inDays < 7) return '${diff.inDays}d';
      return '${dt.day}/${dt.month}';
    } catch (e) {
      return '';
    }
  }
}
