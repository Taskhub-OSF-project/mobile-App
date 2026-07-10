import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../task/data/repositories/task_repository.dart';
import '../../../task/data/models/task_models.dart';
import '../../../../shared/widgets/common_widgets.dart';

class TaskDetailScreen extends ConsumerStatefulWidget {
  final int taskId;

  const TaskDetailScreen({super.key, required this.taskId});

  @override
  ConsumerState<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends ConsumerState<TaskDetailScreen> {
  TaskResponse? _task;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTask();
  }

  Future<void> _loadTask() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final result = await ref.read(taskRepositoryProvider).getTask(widget.taskId);
    if (result.isSuccess && mounted) {
      setState(() {
        _task = result.data;
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() {
        _error = result.error?.message ?? 'Failed to load task';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết công việc'),
        actions: [
          if (_task != null) ...[
            IconButton(
              icon: const Icon(Icons.chat_outlined),
              onPressed: () async {
                final repo = ref.read(messagingRepositoryProvider);
                final result =
                    await repo.getOrCreateConversation(widget.taskId);
                if (result.isSuccess && mounted) {
                  context.push('/messages/${result.data!.id}');
                }
              },
            ),
          ],
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? ErrorDisplay(message: _error!, onRetry: _loadTask)
              : _task == null
                  ? const EmptyState(
                      icon: Icons.error_outline,
                      title: 'Không tìm thấy công việc',
                    )
                  : _buildContent(context, currentUser),
      bottomNavigationBar: _task != null ? _buildBottomBar(context) : null,
    );
  }

  Widget _buildContent(BuildContext context, dynamic currentUser) {
    final task = _task!;
    final isHirer = currentUser?.id == task.hirerId;
    final isAssignee = currentUser?.id == task.assignedToId;

    return RefreshIndicator(
      onRefresh: _loadTask,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                StatusBadge(status: task.status ?? 'DRAFT'),
              ],
            ),
            const SizedBox(height: 16),

            // Budget & Deadline
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: _InfoTile(
                        icon: Icons.attach_money,
                        label: 'Ngân sách',
                        value: '${task.budget.toStringAsFixed(0)} VND',
                        valueColor: AppTheme.accent,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: AppTheme.border,
                    ),
                    Expanded(
                      child: _InfoTile(
                        icon: Icons.calendar_today,
                        label: 'Hạn chót',
                        value: task.deadline?.split('T').first ?? '-',
                        valueColor: AppTheme.warning,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Hirer info
            GestureDetector(
              onTap: () => context.push('/user/${task.hirerId}'),
              child: Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                    child: Text(
                      task.hirerName.isNotEmpty
                          ? task.hirerName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                          color: AppTheme.primary, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(task.hirerName),
                  subtitle: const Text('Người thuê'),
                  trailing: const Icon(Icons.chevron_right),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Description
            Text(
              'Mô tả chi tiết',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(task.description, style: TextStyle(color: Colors.grey[700])),
            const SizedBox(height: 24),

            // Acceptance Criteria
            if (task.acceptanceCriteria != null &&
                task.acceptanceCriteria!.isNotEmpty) ...[
              Text(
                'Tiêu chí nghiệm thu',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              ...task.acceptanceCriteria!.asMap().entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle_outline,
                          size: 20, color: Colors.grey[500]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          entry.value.description,
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 16),
            ],

            // Applicants (for hirers)
            if (isHirer &&
                task.applicants != null &&
                task.applicants!.isNotEmpty) ...[
              Text(
                'Ứng viên (${task.applicants!.length})',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              ...task.applicants!.map((app) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(app.studentName[0].toUpperCase()),
                      ),
                      title: Text(app.studentName),
                      subtitle: Text(app.studentUniversity ?? ''),
                      trailing: app.status == 'PENDING'
                          ? ElevatedButton(
                              onPressed: () async {
                                final repo = ref.read(taskRepositoryProvider);
                                await repo.acceptApplication(app.id);
                                _loadTask();
                              },
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                              ),
                              child: const Text('Chấp nhận'),
                            )
                          : StatusBadge(status: app.status ?? 'PENDING'),
                    ),
                  )),
            ],

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Future<void> _showSubmitDialog() async {
    final notesController = TextEditingController();
    final linkController = TextEditingController();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nộp sản phẩm'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: notesController,
              decoration: const InputDecoration(labelText: 'Ghi chú (Tùy chọn)'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: linkController,
              decoration: const InputDecoration(labelText: 'Đường dẫn File (Tùy chọn)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Nộp')),
        ],
      )
    );
    if (confirm == true && mounted) {
      final repo = ref.read(taskRepositoryProvider);
      final notes = notesController.text.trim();
      final link = linkController.text.trim();
      final res = await repo.submitWork(widget.taskId, notes.isNotEmpty ? notes : null, link.isNotEmpty ? [link] : null);
      if (res.isSuccess) {
         if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nộp sản phẩm thành công')));
         _loadTask();
      } else {
         if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res.error?.message ?? 'Lỗi nộp sản phẩm')));
      }
    }
  }

  Widget _buildBottomBar(BuildContext context) {
    final task = _task!;
    final currentUser = ref.watch(currentUserProvider);
    final isHirer = currentUser?.id == task.hirerId;
    final isAssignee = currentUser?.id == task.assignedToId;
    final isStudent = currentUser?.isStudent ?? false;
    final status = task.status ?? 'DRAFT';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Hirer actions
            if (isHirer) ...[
              if (status == 'DRAFT') ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final repo = ref.read(taskRepositoryProvider);
                      await repo.lockTask(task.id);
                      _loadTask();
                    },
                    child: const Text('Khóa & Tự động duyệt'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final repo = ref.read(taskRepositoryProvider);
                      await repo.fundEscrow(task.id);
                      _loadTask();
                    },
                    child: const Text('Nạp Escrow'),
                  ),
                ),
              ],
              if (status == 'IN_PROGRESS')
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final repo = ref.read(taskRepositoryProvider);
                      await repo.releaseEscrow(task.id);
                      _loadTask();
                    },
                    child: const Text('Duyệt & Thanh toán'),
                  ),
                ),
              if (status == 'SUBMITTED')
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final repo = ref.read(taskRepositoryProvider);
                      await repo.approveSubmission(task.id);
                      _loadTask();
                    },
                    child: const Text('Duyệt bài nộp'),
                  ),
                ),
            ],
            // Student actions
            if (isAssignee) ...[
              if (status == 'IN_PROGRESS')
                Expanded(
                  child: ElevatedButton(
                    onPressed: _showSubmitDialog,
                    child: const Text('Nộp sản phẩm'),
                  ),
                ),
            ],
            // Student can apply
            if (isStudent && task.status == 'ACTIVE') ...[
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    final repo = ref.read(taskRepositoryProvider);
                    final result = await repo.applyToTask(task.id, null);
                    if (result.isSuccess && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Ứng tuyển thành công!')),
                      );
                    } else if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(result.error?.message ??
                                'Ứng tuyển thất bại')),
                      );
                    }
                  },
                  child: const Text('Ứng tuyển'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 24, color: AppTheme.primary),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(fontSize: 12, color: Colors.grey[500])),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
