import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers.dart';
import '../../core/theme/app_theme.dart';

class MainScaffold extends ConsumerStatefulWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  @override
  ConsumerState<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends ConsumerState<MainScaffold> {
  int _currentIndex = 0;

  final _routes = ['/home', '/tasks', '/wallet', '/messages', '/profile'];

  @override
  Widget build(BuildContext context) {
    final unreadMessagesAsync = ref.watch(messageUnreadCountProvider);
    final unreadMessages = unreadMessagesAsync.value ?? 0;
    final currentIdx = _calculateIndex(context);
    final user = ref.watch(currentUserProvider);
    final isHirer = user?.isHirer ?? false;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: widget.child,
      bottomNavigationBar: _buildBottomNav(currentIdx, unreadMessages, isHirer),
    );
  }

  Widget _buildBottomNav(int currentIdx, int unreadMessages, bool isHirer) {
    final items = [
      _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Trang chủ'),
      _NavItem(
        icon: isHirer ? Icons.assignment_outlined : Icons.work_outline_rounded,
        activeIcon: isHirer ? Icons.assignment_rounded : Icons.work_rounded,
        label: isHirer ? 'Công việc' : 'Đang làm'
      ),
      _NavItem(icon: Icons.account_balance_wallet_outlined, activeIcon: Icons.account_balance_wallet_rounded, label: 'Ví'),
      _NavItem(icon: Icons.chat_bubble_outline_rounded, activeIcon: Icons.chat_bubble_rounded, label: 'Tin nhắn', badge: unreadMessages),
      _NavItem(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'Tài khoản'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          top: BorderSide(color: AppTheme.border.withOpacity(0.5), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isActive = index == currentIdx;
              return Expanded(
                child: GestureDetector(
                  onTap: () => _onTap(context, index),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppTheme.primary.withOpacity(0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Pill indicator above icon
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          width: isActive ? 36 : 0,
                          height: 3,
                          margin: const EdgeInsets.only(bottom: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        // Icon with badge
                        Badge(
                          isLabelVisible:
                              item.badge != null && item.badge! > 0,
                          label: Text(
                            '${item.badge ?? 0}',
                            style: const TextStyle(fontSize: 9),
                          ),
                          child: Icon(
                            isActive ? item.activeIcon : item.icon,
                            color: isActive
                                ? AppTheme.primary
                                : AppTheme.textTertiary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          style: GoogleFonts.nunito(
                            fontSize: 10,
                            fontWeight: isActive
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isActive
                                ? AppTheme.primary
                                : AppTheme.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  int _calculateIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/tasks')) return 1;
    if (location.startsWith('/wallet')) return 2;
    if (location.startsWith('/messages')) return 3;
    if (location.startsWith('/profile') || location.startsWith('/user')) return 4;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    if (index != _currentIndex) {
      _currentIndex = index;
      context.go(_routes[index]);
    }
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int? badge;

  _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.badge,
  });
}
