import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../../../../providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/result.dart';
import '../../../../core/models/page_response.dart';
import '../../../task/data/models/task_models.dart';
import '../../../../shared/widgets/common_widgets.dart';

class TaskListScreen extends ConsumerStatefulWidget {
  final bool available;

  const TaskListScreen({super.key, this.available = false});

  @override
  ConsumerState<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends ConsumerState<TaskListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // States for student Search (Tab 0)
  List<PublicTaskResponse> _publicTasks = [];
  bool _isLoadingSearch = true;
  String? _searchError;
  int _searchPage = 0;
  bool _searchHasMore = true;
  String _searchKeyword = '';
  String? _selectedCategory;
  List<String> _categories = [];
  List<int> _appliedTaskIds = [];
  Timer? _debounce;
  final TextEditingController _searchController = TextEditingController();

  // States for other tabs / Hirer
  List<TaskResponse> _tasks = [];
  bool _isLoading = true;
  String? _error;
  int _page = 0;
  bool _hasMore = true;

  bool get _isStudent => !(ref.read(currentUserProvider)?.isHirer ?? false);

  @override
  void initState() {
    super.initState();
    final isStudent = !(ref.read(currentUserProvider)?.isHirer ?? false);
    
    _tabController = TabController(
      length: isStudent ? 5 : 2,
      vsync: this,
      initialIndex: widget.available && isStudent ? 0 : (isStudent ? 2 : 0), 
    );
    
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        if (isStudent && _tabController.index == 0) {
          if (_publicTasks.isEmpty && _searchError == null) {
            _loadSearchTasks(refresh: true);
          }
        } else {
          _loadTasks(refresh: true);
        }
      }
    });

    if (isStudent) {
      _loadCategories();
      if (_tabController.index == 0) {
        _loadSearchTasks();
      } else {
        _loadTasks();
      }
    } else {
      _loadTasks();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    final repo = ref.read(taskRepositoryProvider);
    final res = await repo.getCategories();
    if (res.isSuccess && mounted) {
      setState(() {
        _categories = res.data ?? [];
      });
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_searchKeyword != query) {
        setState(() {
          _searchKeyword = query;
        });
        _loadSearchTasks(refresh: true);
      }
    });
  }

  void _onCategorySelected(String? category) {
    setState(() {
      _selectedCategory = category;
    });
    _loadSearchTasks(refresh: true);
  }

  Future<void> _loadSearchTasks({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _searchPage = 0;
        _publicTasks = [];
        _isLoadingSearch = true;
        _searchError = null;
        _searchHasMore = true;
      });
    }

    final repo = ref.read(taskRepositoryProvider);

    // Fetch applied tasks to filter them out from public tasks
    if (_isStudent && _searchPage == 0) {
      final appliedRes = await repo.getMyAppliedTasks();
      if (appliedRes.isSuccess) {
        _appliedTaskIds = appliedRes.data?.map((t) => t.id).toList() ?? [];
      }
    }

    final result = await repo.searchTasks(
      keyword: _searchKeyword,
      category: _selectedCategory,
      page: _searchPage,
    );

    if (result.isSuccess && mounted) {
      final content = result.data?.content ?? [];
      final filteredContent = _isStudent 
          ? content.where((t) => !_appliedTaskIds.contains(t.id)).toList()
          : content;

      setState(() {
        if (refresh || _searchPage == 0) {
          _publicTasks = filteredContent;
        } else {
          _publicTasks.addAll(filteredContent);
        }
        _searchHasMore = result.data?.hasNext ?? false;
        _isLoadingSearch = false;
      });
    } else if (mounted) {
      setState(() {
        _searchError = result.error?.message ?? 'Lỗi tìm kiếm';
        _isLoadingSearch = false;
      });
    }
  }

  Future<void> _loadMoreSearch() async {
    if (!_searchHasMore || _isLoadingSearch) return;
    _searchPage++;
    await _loadSearchTasks();
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
    final isStudent = _isStudent;
    
    Result<PageResponse<TaskResponse>> result;
    
    if (isStudent) {
      String? status;
      switch (_tabController.index) {
        case 1: status = 'APPLIED'; break;
        case 2: status = 'IN_PROGRESS'; break;
        case 3: status = 'SUBMITTED'; break;
        case 4: status = 'COMPLETED'; break;
      }
      
      if (status == 'APPLIED') {
        final appliedRes = await repo.getMyAppliedTasks();
        if (appliedRes.isSuccess) {
          result = Result.success(PageResponse(
            content: appliedRes.data ?? [],
            page: 0,
            size: appliedRes.data?.length ?? 0,
            totalElements: appliedRes.data?.length ?? 0,
            totalPages: 1,
            first: true,
            last: true,
            hasNext: false,
            hasPrevious: false,
          ));
        } else {
          result = Result.failure(appliedRes.error!);
        }
      } else {
        result = await repo.getMyTasks(status: status, page: _page);
      }
    } else {
      String? status;
      if (_tabController.index == 1) {
        status = 'DRAFT'; 
      }
      result = await repo.getMyTasks(status: status, page: _page);
    }

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
        _error = result.error?.message ?? 'Tải danh sách thất bại';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreTasks() async {
    if (!_hasMore || _isLoading) return;
    _page++;
    await _loadTasks();
  }

  Widget _buildSearchTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: AppTheme.surface,
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm công việc...',
                  prefixIcon: const Icon(Icons.search, color: AppTheme.textTertiary),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: AppTheme.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),
              if (_categories.isNotEmpty) ...[
                const SizedBox(height: 12),
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length + 1,
                    separatorBuilder: (context, index) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        final isSelected = _selectedCategory == null;
                        return ChoiceChip(
                          label: const Text('Tất cả'),
                          selected: isSelected,
                          onSelected: (val) {
                            if (val) _onCategorySelected(null);
                          },
                          selectedColor: AppTheme.primary.withValues(alpha: 0.2),
                          labelStyle: TextStyle(
                            color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        );
                      }
                      final category = _categories[index - 1];
                      final isSelected = _selectedCategory == category;
                      return ChoiceChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (val) {
                          _onCategorySelected(val ? category : null);
                        },
                        selectedColor: AppTheme.primary.withValues(alpha: 0.2),
                        labelStyle: TextStyle(
                          color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => _loadSearchTasks(refresh: true),
            child: _isLoadingSearch && _publicTasks.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _searchError != null && _publicTasks.isEmpty
                    ? ErrorDisplay(
                        message: _searchError!,
                        onRetry: () => _loadSearchTasks(refresh: true),
                      )
                    : _publicTasks.isEmpty
                        ? const EmptyState(
                            icon: Icons.search_off_outlined,
                            title: 'Không tìm thấy kết quả',
                            subtitle: 'Thử điều chỉnh từ khóa hoặc danh mục khác',
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _publicTasks.length + (_searchHasMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == _publicTasks.length) {
                                _loadMoreSearch();
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(16),
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }
                              return _PublicTaskListItem(task: _publicTasks[index]);
                            },
                          ),
          ),
        ),
      ],
    );
  }

  Widget _buildStandardTab() {
    return RefreshIndicator(
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
                      title: 'Chưa có công việc nào',
                      subtitle: 'Chưa có dữ liệu cho trạng thái này',
                      action: !_isStudent
                          ? ElevatedButton.icon(
                              onPressed: () => context.push('/tasks/create'),
                              icon: const Icon(Icons.add),
                              label: const Text('Đăng việc'),
                            )
                          : null,
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _tasks.length + (_hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _tasks.length) {
                          _loadMoreTasks();
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final isStudent = _isStudent;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý công việc'),
        actions: [
          if (!isStudent)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => context.push('/tasks/create'),
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: isStudent
              ? const [
                  Tab(text: 'Việc đang mở'),
                  Tab(text: 'Đã ứng tuyển'),
                  Tab(text: 'Đang làm'),
                  Tab(text: 'Đã nộp'),
                  Tab(text: 'Hoàn tất'),
                ]
              : const [
                  Tab(text: 'Tất cả'),
                  Tab(text: 'Đã đăng'),
                ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: isStudent
            ? [
                _buildSearchTab(),
                _buildStandardTab(),
                _buildStandardTab(),
                _buildStandardTab(),
                _buildStandardTab(),
              ]
            : [
                _buildStandardTab(),
                _buildStandardTab(),
              ],
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
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
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
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${task.budget.toStringAsFixed(0)} VND',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.accent, fontSize: 13),
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.people_outline, size: 16, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text('${task.applicants?.length ?? 0}', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PublicTaskListItem extends StatelessWidget {
  final PublicTaskResponse task;
  const _PublicTaskListItem({required this.task});

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
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  StatusBadge(status: task.status ?? 'AVAILABLE'),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                task.description,
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (task.category != null) ...[
                const SizedBox(height: 8),
                Text('Danh mục: ${task.category}', style: TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.w600)),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${task.budget} VND',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.accent, fontSize: 13),
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.people_outline, size: 16, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text('${task.applicantCount ?? 0}', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
