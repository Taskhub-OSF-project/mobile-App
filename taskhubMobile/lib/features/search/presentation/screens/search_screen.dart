import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../providers.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/search_result_card.dart';
import '../../../task/presentation/screens/task_list_screen.dart'; // To reuse TaskCard
import '../../../task/data/models/task_models.dart';
import '../../data/models/search_models.dart';
import '../../../../shared/widgets/common_widgets.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/repositories/search_repository.dart';
import 'package:go_router/go_router.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  String _query = '';
  bool _isSearchingTasks = true;
  bool _isLoading = false;
  String? _error;
  
  List<TaskResponse> _taskResults = [];
  List<FreelancerSearchResponse> _freelancerResults = [];
  
  void _onSearch(String query) async {
    setState(() {
      _query = query;
      _isLoading = true;
      _error = null;
    });

    if (query.isEmpty) {
      setState(() {
        _taskResults = [];
        _freelancerResults = [];
        _isLoading = false;
      });
      return;
    }

    try {
      final repo = ref.read(searchRepositoryProvider);
      if (_isSearchingTasks) {
        final result = await repo.searchTasks(query: query);
        if (result.isSuccess && mounted) {
          setState(() {
            _taskResults = result.data?.content ?? [];
            _isLoading = false;
          });
        } else if (mounted) {
          setState(() {
            _error = result.error?.message ?? 'Lỗi tìm kiếm';
            _isLoading = false;
          });
        }
      } else {
        final result = await repo.searchFreelancers(query: query);
        if (result.isSuccess && mounted) {
          setState(() {
            _freelancerResults = result.data?.content ?? [];
            _isLoading = false;
          });
        } else if (mounted) {
          setState(() {
            _error = result.error?.message ?? 'Lỗi tìm kiếm';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Đã xảy ra lỗi';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tìm kiếm'),
        titleSpacing: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SearchBarWidget(
              hintText: _isSearchingTasks ? 'Tìm công việc...' : 'Tìm freelancer...',
              onSearch: _onSearch,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ChoiceChip(
                label: const Text('Công việc'),
                selected: _isSearchingTasks,
                onSelected: (val) {
                  setState(() {
                    _isSearchingTasks = true;
                    _onSearch(_query);
                  });
                },
              ),
              const SizedBox(width: 16),
              ChoiceChip(
                label: const Text('Freelancer'),
                selected: !_isSearchingTasks,
                onSelected: (val) {
                  setState(() {
                    _isSearchingTasks = false;
                    _onSearch(_query);
                  });
                },
              ),
            ],
          ),
          const Divider(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? ErrorDisplay(
                        message: _error!,
                        onRetry: () => _onSearch(_query),
                      )
                    : _query.isEmpty
                        ? const Center(
                            child: Text('Nhập từ khóa để tìm kiếm',
                                style: TextStyle(color: Colors.grey)))
                        : _isSearchingTasks
                            ? _buildTaskResults()
                            : _buildFreelancerResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskResults() {
    if (_taskResults.isEmpty) {
      return const EmptyState(
        icon: Icons.search_off,
        title: 'Không tìm thấy kết quả',
        subtitle: 'Thử lại với từ khóa khác',
      );
    }
    return ListView.builder(
      itemCount: _taskResults.length,
      itemBuilder: (context, index) {
        final task = _taskResults[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(task.category ?? ''),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/tasks/${task.id}'),
          ),
        );
      },
    );
  }

  Widget _buildFreelancerResults() {
    if (_freelancerResults.isEmpty) {
      return const EmptyState(
        icon: Icons.search_off,
        title: 'Không tìm thấy kết quả',
        subtitle: 'Thử lại với từ khóa khác',
      );
    }
    return ListView.builder(
      itemCount: _freelancerResults.length,
      itemBuilder: (context, index) {
        return FreelancerSearchCard(freelancer: _freelancerResults[index]);
      },
    );
  }
}
