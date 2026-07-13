import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'providers.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';
import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/auth/presentation/screens/onboarding_screen.dart';
import 'features/auth/presentation/screens/forgot_password_screen.dart';
import 'features/auth/presentation/screens/otp_verification_screen.dart';
import 'features/auth/presentation/screens/reset_password_screen.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/task/presentation/screens/task_list_screen.dart';
import 'features/task/presentation/screens/task_detail_screen.dart';
import 'features/task/presentation/screens/create_task_screen.dart';
import 'features/user/presentation/screens/profile_screen.dart';
import 'features/user/presentation/screens/edit_profile_screen.dart';
import 'features/user/presentation/screens/user_profile_screen.dart';
import 'features/wallet/presentation/screens/wallet_screen.dart';
import 'features/notification/presentation/screens/notification_screen.dart';
import 'features/messaging/presentation/screens/conversation_list_screen.dart';
import 'features/messaging/presentation/screens/chat_screen.dart';
import 'features/search/presentation/screens/search_screen.dart';
import 'shared/widgets/main_scaffold.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(ref),
    redirect: (context, state) {
      final authState = ref.read(authNotifierProvider);
      final isAuth = authState.isAuthenticated;
      final isLoggingIn = state.matchedLocation == '/login';
      final isRegistering = state.matchedLocation == '/register';
      final isSplash = state.matchedLocation == '/';
      final isOnboarding = state.matchedLocation == '/onboarding';
      final isAuthRoute = isLoggingIn || isRegistering || isSplash || isOnboarding ||
          state.matchedLocation == '/forgot-password' ||
          state.matchedLocation == '/otp-verify' ||
          state.matchedLocation == '/reset-password';

      if (authState.status == AuthStatus.initial ||
          authState.status == AuthStatus.loading) {
        return null;
      }

      if (!isAuth && !isAuthRoute) {
        return '/login';
      }

      if (isAuth && (isLoggingIn || isRegistering || isSplash || isOnboarding)) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/otp-verify',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return OtpVerificationScreen(
            phone: extra['phone'] as String? ?? '',
            type: extra['type'] as String? ?? 'RECOVERY',
          );
        },
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return ResetPasswordScreen(
            phone: extra['phone'] as String? ?? '',
            code: extra['code'] as String? ?? '',
          );
        },
      ),
      ShellRoute(
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/tasks',
            builder: (context, state) => const TaskListScreen(),
          ),
          GoRoute(
            path: '/tasks/available',
            builder: (context, state) => const TaskListScreen(available: true),
          ),
          GoRoute(
            path: '/tasks/create',
            builder: (context, state) => const CreateTaskScreen(),
          ),
          GoRoute(
            path: '/tasks/:id',
            builder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              return TaskDetailScreen(taskId: id);
            },
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/profile/edit',
            builder: (context, state) => const EditProfileScreen(),
          ),
          GoRoute(
            path: '/user/:id',
            builder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              return UserProfileScreen(userId: id);
            },
          ),
          GoRoute(
            path: '/wallet',
            builder: (context, state) => const WalletScreen(),
          ),
          GoRoute(
            path: '/notifications',
            builder: (context, state) => const NotificationScreen(),
          ),
          GoRoute(
            path: '/search',
            builder: (context, state) => const SearchScreen(),
          ),
          GoRoute(
            path: '/messages',
            builder: (context, state) => const ConversationListScreen(),
          ),
          GoRoute(
            path: '/messages/:id',
            builder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              return ChatScreen(conversationId: id);
            },
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.error}')),
    ),
  );
});

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(this.ref) {
    ref.listen(authNotifierProvider, (previous, next) {
      notifyListeners();
    });
  }

  final Ref ref;
}
