import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/notification_models.dart';
import '../../../../shared/widgets/common_widgets.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  List<NotificationResponse> _notifications = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() { _isLoading = true; _error = null; });
    final result = await ref.read(notificationRepositoryProvider).getNotifications();
    if (result.isSuccess && mounted) {
      setState(() { _notifications = result.data?.content ?? []; _isLoading = false; });
    } else if (mounted) {
      setState(() { _error = result.error?.message ?? 'Failed to load notifications'; _isLoading = false; });
    }
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'TASK_ASSIGNED': return Icons.assignment_ind;
      case 'TASK_APPLICATION_RECEIVED': return Icons.person_add;
      case 'TASK_APPLICATION_ACCEPTED': return Icons.check_circle;
      case 'TASK_APPLICATION_REJECTED': return Icons.cancel;
      case 'TASK_SUBMITTED': return Icons.upload_file;
      case 'TASK_REVISION_REQUESTED': return Icons.edit_note;
      case 'TASK_APPROVED': return Icons.verified;
      case 'TASK_COMPLETED': return Icons.done_all;
      case 'TASK_DISPUTE_OPENED': return Icons.warning;
      case 'PAYMENT_RECEIVED': return Icons.attach_money;
      case 'PAYMENT_SENT': return Icons.money_off;
      case 'SYSTEM_ANNOUNCEMENT': return Icons.campaign;
      default: return Icons.notifications;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'TASK_ASSIGNED': case 'TASK_APPLICATION_RECEIVED': return AppTheme.info;
      case 'TASK_APPLICATION_ACCEPTED': case 'TASK_APPROVED': case 'TASK_COMPLETED': return AppTheme.success;
      case 'TASK_APPLICATION_REJECTED': case 'TASK_DISPUTE_OPENED': return AppTheme.error;
      case 'TASK_REVISION_REQUESTED': return AppTheme.warning;
      case 'PAYMENT_RECEIVED': return AppTheme.accent;
      default: return AppTheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () async {
              await ref.read(notificationRepositoryProvider).markAllAsRead();
              _loadNotifications();
            },
            child: const Text('Mark all read'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? ErrorDisplay(message: _error!, onRetry: _loadNotifications)
              : _notifications.isEmpty
                  ? const EmptyState(
                      icon: Icons.notifications_off_outlined,
                      title: 'No notifications',
                      subtitle: "You're all caught up!",
                    )
                  : RefreshIndicator(
                      onRefresh: _loadNotifications,
                      child: ListView.builder(
                        itemCount: _notifications.length,
                        itemBuilder: (context, index) {
                          final notif = _notifications[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            color: notif.isRead == true ? null : AppTheme.primary.withValues(alpha: 0.03),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _getColorForType(notif.type).withValues(alpha: 0.1),
                                child: Icon(_getIconForType(notif.type), color: _getColorForType(notif.type), size: 20),
                              ),
                              title: Text(notif.title, style: TextStyle(fontWeight: notif.isRead == true ? FontWeight.normal : FontWeight.bold)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(notif.message, maxLines: 2, overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 4),
                                  Text(_formatTime(notif.createdAt), style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                                ],
                              ),
                              onTap: () { if (notif.taskId != null) { context.push('/tasks/${notif.taskId}'); } },
                            ),
                          );
                        },
                      ),
                    ),
    );
  }

  String _formatTime(String iso) {
    try {
      final dt = DateTime.parse(iso);
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (e) { return ''; }
  }
}