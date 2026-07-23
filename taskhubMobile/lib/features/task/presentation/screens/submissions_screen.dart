import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../task/data/models/task_models.dart';
import '../../../../shared/widgets/common_widgets.dart';
import 'package:intl/intl.dart';

class SubmissionsScreen extends ConsumerStatefulWidget {
  const SubmissionsScreen({super.key});

  @override
  ConsumerState<SubmissionsScreen> createState() => _SubmissionsScreenState();
}

class _SubmissionsScreenState extends ConsumerState<SubmissionsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  bool _isLoading = true;
  String? _error;
  
  // Data
  List<TaskResponse> _allTasks = [];
  int _submittedCount = 0;
  int _completedCount = 0;
  int _revisionCount = 0;
  int _disputedCount = 0;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = ref.read(currentUserProvider);
      final repo = ref.read(taskRepositoryProvider);
      
      // Load all tasks related to submissions
      // For simplicity in this UI, we load all tasks and filter locally.
      // In a real app with large data, we would use pagination per tab.
      final result = await repo.getMyTasks(size: 100); 
      
      if (result.isSuccess && mounted) {
        final tasks = result.data?.content ?? [];
        
        // Filter tasks that are actually in a submission-related state
        _allTasks = tasks.where((t) => 
          t.statusEnum == TaskStatus.SUBMITTED || 
          t.statusEnum == TaskStatus.COMPLETED || 
          t.statusEnum == TaskStatus.IN_PROGRESS ||
          t.statusEnum == TaskStatus.DISPUTED
        ).toList();
        
        _submittedCount = _allTasks.where((t) => t.statusEnum == TaskStatus.SUBMITTED).length;
        _completedCount = _allTasks.where((t) => t.statusEnum == TaskStatus.COMPLETED).length;
        _revisionCount = _allTasks.where((t) => t.statusEnum == TaskStatus.IN_PROGRESS).length;
        _disputedCount = _allTasks.where((t) => t.statusEnum == TaskStatus.DISPUTED).length;
        
        setState(() {
          _isLoading = false;
        });
      } else if (mounted) {
        setState(() {
          _error = result.error?.message ?? 'Không thể tải dữ liệu';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Đã xảy ra lỗi: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final isHirer = user?.isHirer ?? false;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textPrimary, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isHirer ? 'Duyệt bài nộp' : 'Bài đã nộp',
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            Text(
              isHirer 
                ? 'Xem xét và phê duyệt bài nộp của sinh viên.' 
                : 'Theo dõi bài nộp, phản hồi và trạng thái duyệt.',
              style: GoogleFonts.nunito(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : _error != null
              ? ErrorDisplay(message: _error!, onRetry: _loadData)
              : Column(
                  children: [
                    _buildStatsCards(isHirer),
                    const SizedBox(height: 16),
                    _buildTabBar(isHirer),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildTaskList(_allTasks, isHirer), // Tất cả
                          _buildTaskList(_allTasks.where((t) => t.statusEnum == TaskStatus.SUBMITTED).toList(), isHirer),
                          _buildTaskList(_allTasks.where((t) => t.statusEnum == TaskStatus.COMPLETED).toList(), isHirer),
                          _buildTaskList(_allTasks.where((t) => t.statusEnum == (isHirer ? TaskStatus.IN_PROGRESS : TaskStatus.IN_PROGRESS)).toList(), isHirer),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildStatsCards(bool isHirer) {
    if (isHirer) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Chờ duyệt',
                value: _submittedCount,
                color: const Color(0xFFF59E0B), // Orange
                icon: Icons.access_time_rounded,
                bgColor: const Color(0xFFFEF3C7),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatCard(
                title: 'Đã giải ngân',
                value: _completedCount,
                color: const Color(0xFF10B981), // Green
                icon: Icons.check_circle_outline_rounded,
                bgColor: const Color(0xFFD1FAE5),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatCard(
                title: 'Đang khiếu nại',
                value: _disputedCount,
                color: const Color(0xFFEF4444), // Red
                icon: Icons.error_outline_rounded,
                bgColor: const Color(0xFFFEE2E2),
              ),
            ),
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Đã nộp',
                value: _submittedCount,
                color: const Color(0xFF3B82F6), // Blue
                icon: Icons.description_outlined,
                bgColor: const Color(0xFFDBEAFE),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatCard(
                title: 'Đã duyệt',
                value: _completedCount,
                color: const Color(0xFF10B981), // Green
                icon: Icons.check_circle_outline_rounded,
                bgColor: const Color(0xFFD1FAE5),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatCard(
                title: 'Cần sửa',
                value: _revisionCount,
                color: const Color(0xFFF59E0B), // Orange
                icon: Icons.warning_amber_rounded,
                bgColor: const Color(0xFFFEF3C7),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildTabBar(bool isHirer) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppTheme.border.withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: AppTheme.primary,
        unselectedLabelColor: AppTheme.textSecondary,
        indicatorColor: AppTheme.primary,
        indicatorWeight: 3,
        labelStyle: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 14),
        unselectedLabelStyle: GoogleFonts.nunito(fontWeight: FontWeight.w600, fontSize: 14),
        tabs: [
          const Tab(text: 'Tất cả'),
          const Tab(text: 'Chờ duyệt'),
          const Tab(text: 'Đã duyệt'),
          Tab(text: isHirer ? 'Chỉnh sửa' : 'Cần sửa'),
        ],
      ),
    );
  }

  Widget _buildTaskList(List<TaskResponse> tasks, bool isHirer) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.description_outlined, size: 48, color: AppTheme.textTertiary.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              isHirer ? 'Chưa có bài nộp nào' : 'Chưa có bài nộp',
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isHirer ? 'Sinh viên chưa nộp bài cho công việc nào' : 'Bạn chưa nộp bài cho công việc nào',
              style: GoogleFonts.nunito(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppTheme.primary,
      backgroundColor: AppTheme.surface,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: tasks.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final task = tasks[index];
          return _SubmissionCard(task: task);
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final int value;
  final Color color;
  final IconData icon;
  final Color bgColor;

  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color.withOpacity(0.8),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(icon, size: 16, color: color),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value.toString(),
            style: GoogleFonts.nunito(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _SubmissionCard extends StatelessWidget {
  final TaskResponse task;

  const _SubmissionCard({required this.task});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border.withOpacity(0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => context.push('/tasks/${task.id}'), // Navigate to task detail for submission handling
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: GoogleFonts.nunito(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: AppTheme.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          task.hirerName,
                          style: GoogleFonts.nunito(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  StatusBadge(status: task.status ?? 'DRAFT'),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 14, color: AppTheme.textTertiary),
                  const SizedBox(width: 4),
                  Text(
                    'Tạo ngày: ${dateFormat.format(DateTime.parse(task.createdAt))}',
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      color: AppTheme.textTertiary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${task.budget.toStringAsFixed(0)} VND',
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primary,
                      fontSize: 14,
                    ),
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
