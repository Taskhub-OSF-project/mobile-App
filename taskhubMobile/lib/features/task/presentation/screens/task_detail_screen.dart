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
        title: const Text('Task Details'),
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
                      title: 'Task not found',
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
                        label: 'Budget',
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
                        label: 'Deadline',
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
                  subtitle: const Text('Hirer'),
                  trailing: const Icon(Icons.chevron_right),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Description
            Text(
              'Description',
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
                'Acceptance Criteria',
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
                'Applicants (${task.applicants!.length})',
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
                              child: const Text('Accept'),
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
                    child: const Text('Lock & Validate'),
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
                    child: const Text('Fund Escrow'),
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
                    child: const Text('Approve & Release'),
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
                    child: const Text('Approve Submission'),
                  ),
                ),
            ],
            // Student actions
            if (isAssignee) ...[
              if (status == 'IN_PROGRESS')
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Navigate to submit screen
                    },
                    child: const Text('Submit Work'),
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
                        const SnackBar(content: Text('Applied successfully!')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(result.error?.message ??
                                'Failed to apply')),
                      );
                    }
                  },
                  child: const Text('Apply for this Task'),
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
