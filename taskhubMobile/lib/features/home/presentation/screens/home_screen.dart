import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../task/data/models/task_models.dart';
import '../../../../shared/widgets/common_widgets.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  List<TaskResponse> _tasksList = [];
  double _escrowBalance = 0;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = ref.read(currentUserProvider);
      final repo = ref.read(taskRepositoryProvider);

      if (user != null && user.isHirer) {
        final result = await repo.getMyTasks(size: 1000);
        if (result.isSuccess && mounted) {
          final allTasks = result.data?.content ?? [];
          final escrowedStatuses = ["ESCROW_FUNDED", "ACTIVE", "IN_PROGRESS", "SUBMITTED", "DISPUTED"];
          double computedEscrow = 0;
          for (var t in allTasks) {
            if (escrowedStatuses.contains(t.status)) {
              computedEscrow += t.budget * 1.05;
            }
          }
          setState(() {
            _tasksList = allTasks.take(5).toList();
            _escrowBalance = computedEscrow;
            _isLoading = false;
          });
        } else if (mounted) {
          setState(() {
            _error = result.error?.message ?? 'Không thể tải dữ liệu';
            _isLoading = false;
          });
        }
      } else {
        final result = await repo.getAvailableTasks();
        if (result.isSuccess && mounted) {
          setState(() {
            _tasksList = (result.data?.content ?? []).take(5).toList();
            _isLoading = false;
          });
        } else if (mounted) {
          setState(() {
            _error = result.error?.message ?? 'Không thể tải dữ liệu';
            _isLoading = false;
          });
        }
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

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Xin chào, ${user?.fullName ?? 'bạn'}! 👋',
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            Text(
              'Hôm nay bạn thế nào?',
              style: GoogleFonts.nunito(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          Consumer(
            builder: (context, ref, child) {
              final unreadCountAsync = ref.watch(notificationUnreadCountProvider);
              final unreadCount = unreadCountAsync.value ?? 0;
              return Container(
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.border.withOpacity(0.6)),
                ),
                child: IconButton(
                  icon: Badge(
                    isLabelVisible: unreadCount > 0,
                    label: Text(unreadCount.toString()),
                    child: const Icon(Icons.notifications_outlined,
                        color: AppTheme.textPrimary),
                  ),
                  onPressed: () => context.push('/notifications'),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppTheme.primary,
        backgroundColor: AppTheme.surface,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Wallet Card
              _buildWalletCard(user),
              const SizedBox(height: 24),

              // Section title: Quick actions
              Text(
                'Phím tắt nhanh',
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              // Quick action buttons grid
              _buildQuickActions(context, user),
              const SizedBox(height: 24),

              // Task List section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Công việc gần đây',
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push(
                        user?.isHirer == true ? '/tasks' : '/tasks/available'),
                    child: Text(
                      'Xem tất cả',
                      style: GoogleFonts.nunito(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (_isLoading)
                const Center(
                    child: CircularProgressIndicator(color: AppTheme.primary))
              else if (_error != null)
                ErrorDisplay(message: _error!, onRetry: _loadData)
              else if (_tasksList.isEmpty)
                _buildEmptyProjects()
              else
                ..._tasksList.map((task) => _TaskCard(task: task)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWalletCard(dynamic user) {
    final isHirer = user?.isHirer ?? false;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF10B981), // emerald-500
            Color(0xFF059669), // emerald-600
            Color(0xFF047857), // emerald-700
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF059669).withOpacity(0.45),
            blurRadius: 28,
            spreadRadius: 0,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.25),
            blurRadius: 16,
            spreadRadius: -4,
            offset: const Offset(-4, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isHirer ? 'Ví Hirer' : 'Ví Freelancer',
                      style: GoogleFonts.nunito(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Số dư khả dụng',
                      style: GoogleFonts.nunito(
                        color: Colors.white.withOpacity(0.65),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    _WalletActionBtn(
                      icon: Icons.add,
                      label: 'Nạp tiền',
                      onTap: () => context.push('/wallet'),
                    ),
                    const SizedBox(width: 10),
                    _WalletActionBtn(
                      icon: Icons.arrow_forward,
                      label: 'Rút tiền',
                      onTap: () => context.push('/wallet'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${_formatBalance(user?.walletBalance ?? 0)} VND',
              style: GoogleFonts.nunito(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 1,
              color: Colors.white.withOpacity(0.2),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    label: isHirer ? 'Đã đăng' : 'Hoàn thành',
                    value: isHirer
                        ? '${user?.completedTasksAsHirer ?? 0}'
                        : '${user?.completedTasksAsFreelancer ?? 0}',
                  ),
                ),
                Container(width: 1, height: 32, color: Colors.white.withOpacity(0.2)),
                if (isHirer) ...[
                  Expanded(
                    child: _StatItem(
                      label: 'Đang ký quỹ',
                      value: _formatBalance(_escrowBalance),
                      suffix: ' đ',
                    ),
                  ),
                  Container(width: 1, height: 32, color: Colors.white.withOpacity(0.2)),
                ],
                Expanded(
                  child: _StatItem(
                    label: 'Đánh giá',
                    value: isHirer
                        ? (user?.averageRatingAsHirer?.toStringAsFixed(1) ?? '–')
                        : (user?.averageRatingAsFreelancer?.toStringAsFixed(1) ?? '–'),
                    suffix: ' ⭐',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatBalance(double balance) {
    if (balance >= 1000000) {
      return '${(balance / 1000000).toStringAsFixed(1)}M';
    } else if (balance >= 1000) {
      return '${(balance / 1000).toStringAsFixed(0)}K';
    }
    return balance.toStringAsFixed(0);
  }

  Widget _buildQuickActions(BuildContext context, dynamic user) {
    final isHirer = user?.isHirer ?? false;

    final hirerActions = <Map<String, dynamic>>[
      {
        'icon': Icons.add_circle_outline_rounded,
        'label': 'Đăng việc',
        'onTap': () => context.push('/tasks/create'),
        'color': const Color(0xFF10B981),
      },
      {
        'icon': Icons.assignment_rounded,
        'label': 'Công việc',
        'onTap': () => context.push('/tasks'),
        'color': const Color(0xFF3B82F6),
      },
      {
        'icon': Icons.assignment_turned_in_rounded,
        'label': 'Bài nộp',
        'onTap': () => context.push('/submissions'),
        'color': const Color(0xFF8B5CF6),
      },
      {
        'icon': Icons.account_balance_wallet_rounded,
        'label': 'Ví của tôi',
        'onTap': () => context.push('/wallet'),
        'color': const Color(0xFF059669),
      },
      {
        'icon': Icons.chat_bubble_rounded,
        'label': 'Tin nhắn',
        'onTap': () => context.push('/messages'),
        'color': const Color(0xFFF59E0B),
      },
    ];

    final studentActions = <Map<String, dynamic>>[
      {
        'icon': Icons.search_rounded,
        'label': 'Tìm việc',
        'onTap': () => context.push('/tasks/available'),
        'color': const Color(0xFF3B82F6),
      },
      {
        'icon': Icons.work_rounded,
        'label': 'Đang làm',
        'onTap': () => context.push('/tasks'),
        'color': const Color(0xFF10B981),
      },
      {
        'icon': Icons.assignment_turned_in_rounded,
        'label': 'Bài nộp',
        'onTap': () => context.push('/submissions'),
        'color': const Color(0xFFEF4444),
      },
      {
        'icon': Icons.account_balance_wallet_rounded,
        'label': 'Ví của tôi',
        'onTap': () => context.push('/wallet'),
        'color': const Color(0xFF059669),
      },
      {
        'icon': Icons.chat_bubble_rounded,
        'label': 'Tin nhắn',
        'onTap': () => context.push('/messages'),
        'color': const Color(0xFFF59E0B),
      },
      {
        'icon': Icons.person_rounded,
        'label': 'Hồ sơ',
        'onTap': () => context.push('/profile'),
        'color': const Color(0xFF8B5CF6),
      },
    ];

    final actions = isHirer ? hirerActions : studentActions;

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.1,
      children: actions
          .map((a) => _QuickAction(
                icon: a['icon'] as IconData,
                label: a['label'] as String,
                color: a['color'] as Color,
                onTap: a['onTap'] as VoidCallback,
              ))
          .toList(),
    );
  }

  Widget _buildEmptyProjects() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.border.withOpacity(0.5),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.work_outline_rounded,
                color: AppTheme.primary, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            'Chưa có công việc nào',
            style: GoogleFonts.nunito(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Các công việc gần đây sẽ hiển thị tại đây',
            style: GoogleFonts.nunito(
              color: AppTheme.textSecondary,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── Wallet action button ────────────────────────────────────────────────────

class _WalletActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _WalletActionBtn({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withOpacity(0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: Colors.white),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.nunito(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Stat item inside wallet card ────────────────────────────────────────────

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final String? suffix;

  const _StatItem({required this.label, required this.value, this.suffix});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.nunito(
              color: Colors.white.withOpacity(0.65),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$value${suffix ?? ''}',
            style: GoogleFonts.nunito(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Quick action button ─────────────────────────────────────────────────────

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.border.withOpacity(0.7)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: 11,
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Task card ───────────────────────────────────────────────────────────────

class _TaskCard extends StatelessWidget {
  final TaskResponse task;

  const _TaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border.withOpacity(0.6)),
      ),
      child: InkWell(
        onTap: () => context.push('/tasks/${task.id}'),
        borderRadius: BorderRadius.circular(18),
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
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppTheme.textPrimary,
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
                style: GoogleFonts.nunito(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${task.budget.toStringAsFixed(0)} VND',
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (task.category != null) ...[
                    Icon(Icons.category_outlined,
                        size: 13, color: AppTheme.textTertiary),
                    const SizedBox(width: 4),
                    Text(
                      task.category!,
                      style: GoogleFonts.nunito(
                          fontSize: 12, color: AppTheme.textTertiary),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
