import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../task/data/repositories/task_repository.dart';
import '../../../task/data/models/task_models.dart';
import '../../../../shared/widgets/common_widgets.dart';

class TaskListScreen extends ConsumerStatefulWidget {
  final bool available;

  const TaskListScreen({super.key, this.available = false});

  @override
  ConsumerState<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends ConsumerState<TaskListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<TaskResponse> _tasks = [];
  bool _isLoading = true;
  String? _error;
  int _page = 0;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.available ? 1 : 3,
      vsync: this,
    );
    _loadTasks();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTasks({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _page = 0;
        _tasks = [];
        _isLoading = true;
        _error = null;
        _hasMore = true;
      });
    }

    final repo = ref.read(taskRepositoryProvider);
    final result = widget.available
        ? await repo.getAvailableTasks(page: _page)
        : await repo.getMyTasks(page: _page);

    if (result.isSuccess && mounted) {
      final content = result.data?.content ?? [];
      setState(() {
        if (refresh || _page == 0) {
          _tasks = content;
        } else {
          _tasks.addAll(content);
        }
        _hasMore = result.data?.hasNext ?? false;
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() {
        _error = result.error?.message ?? 'Failed to load tasks';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (!_hasMore || _isLoading) return;
    _page++;
    await _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.available ? 'Available Tasks' : 'My Tasks'),
        actions: [
          if (!widget.available && (user?.isHirer ?? false))
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => context.push('/tasks/create'),
            ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Search
            },
          ),
        ],
        bottom: widget.available
            ? null
            : TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'All'),
                  Tab(text: 'Posted'),
                  Tab(text: 'Applied'),
                ],
              ),
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadTasks(refresh: true),
        child: _isLoading && _tasks.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : _error != null && _tasks.isEmpty
                ? ErrorDisplay(
                    message: _error!,
                    onRetry: () => _loadTasks(refresh: true),
                  )
                : _tasks.isEmpty
                    ? EmptyState(
                        icon: Icons.assignment_outlined,
                        title: 'No tasks found',
                        subtitle: widget.available
                            ? 'Check back later for new opportunities'
                            : "You haven't created or applied to any tasks yet",
                        action: widget.available
                            ? null
                            : ElevatedButton.icon(
                                onPressed: () => context.push('/tasks/create'),
                                icon: const Icon(Icons.add),
                                label: const Text('Create Task'),
                              ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _tasks.length + (_hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _tasks.length) {
                            _loadMore();
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          return _TaskListItem(task: _tasks[index]);
                        },
                      ),
      ),
    );
  }
}

class _TaskListItem extends StatelessWidget {
  final TaskResponse task;

  const _TaskListItem({required this.task});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.push('/tasks/${task.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  StatusBadge(status: task.status ?? 'DRAFT'),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                task.description,
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${task.budget.toStringAsFixed(0)} VND',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.accent,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.people_outline, size: 16, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    '${task.applicants?.length ?? 0}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
