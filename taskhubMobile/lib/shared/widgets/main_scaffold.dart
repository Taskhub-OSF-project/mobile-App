import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers.dart';

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

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _calculateIndex(context),
        onTap: (index) => _onTap(context, index),
        type: BottomNavigationBarType.fixed,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
            label: 'Công việc',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet),
            label: 'Ví',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: unreadMessages > 0,
              label: Text(unreadMessages.toString()),
              child: const Icon(Icons.chat_bubble_outline),
            ),
            activeIcon: Badge(
              isLabelVisible: unreadMessages > 0,
              label: Text(unreadMessages.toString()),
              child: const Icon(Icons.chat_bubble),
            ),
            label: 'Tin nhắn',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Hồ sơ',
          ),
        ],
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
