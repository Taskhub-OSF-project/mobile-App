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
          print('Splash: Routing to /login');
          context.go('/login');
        }
      } catch (e) {
        print('Splash: Exception caught: $e');
        if (!mounted) return;
        context.go('/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.primary, AppTheme.primaryDark],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.assignment_outlined,
                  size: 48,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'TaskHub',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Freelance platform for students',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 48),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
