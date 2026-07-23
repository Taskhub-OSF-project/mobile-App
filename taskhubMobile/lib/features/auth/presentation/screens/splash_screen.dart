import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../providers.dart';
import '../../../../core/theme/app_theme.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      print('Splash: Starting init');
      try {
        print('Splash: Calling checkAuthStatus');
        await ref
            .read(authNotifierProvider.notifier)
            .checkAuthStatus()
            .timeout(const Duration(seconds: 5));
            
        print('Splash: checkAuthStatus completed');
        if (!mounted) return;
        final isAuthenticated = ref.read(authNotifierProvider).isAuthenticated;
        
        print('Splash: isAuthenticated = $isAuthenticated');
        if (isAuthenticated) {
          print('Splash: Routing to /home');
          context.go('/home');
        } else {
          final storage = ref.read(secureStorageProvider);
          final hasSeenOnboarding = await storage.read('has_seen_onboarding') == 'true';
          if (hasSeenOnboarding) {
            print('Splash: Routing to /login');
            context.go('/login');
          } else {
            print('Splash: Routing to /onboarding');
            context.go('/onboarding');
          }
        }
      } catch (e) {
        print('Splash: Exception caught: $e');
        if (!mounted) return;
        final storage = ref.read(secureStorageProvider);
        final hasSeenOnboarding = await storage.read('has_seen_onboarding') == 'true';
        if (hasSeenOnboarding) {
          context.go('/login');
        } else {
          context.go('/onboarding');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF059669), // Emerald 600
                    Color(0xFF0D9488), // Teal 600
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF059669).withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.bolt,
                size: 44,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
                children: [
                  TextSpan(
                    text: 'Task',
                    style: TextStyle(color: AppTheme.textPrimary),
                  ),
                  TextSpan(
                    text: 'Hub',
                    style: TextStyle(color: Color(0xFF059669)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Freelance platform for students',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
            ),
          ],
        ),
      ),
    );
  }
}
