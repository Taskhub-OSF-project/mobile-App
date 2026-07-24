import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/common_widgets.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _loginByPhone = false;

  // Google Sign-In state
  String? _pendingGoogleCredential;
  String _selectedGoogleRole = 'STUDENT';

  static const _webClientId =
      '547513175107-8ontkvmfur1r9giot2d98o1lufeiv1lm.apps.googleusercontent.com';

  final _googleSignIn = GoogleSignIn(
    serverClientId: _webClientId,
  );

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      bool success;
      if (_loginByPhone) {
        success = await ref.read(authNotifierProvider.notifier).loginByPhone(
              _phoneController.text.trim(),
              _passwordController.text,
            );
      } else {
        success = await ref.read(authNotifierProvider.notifier).login(
              _emailController.text.trim(),
              _passwordController.text,
            );
      }

      if (success && mounted) {
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đăng nhập thất bại: $e')),
        );
      }
      ref.read(authNotifierProvider.notifier).clearError();
    }
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      await _googleSignIn.signOut(); // Đảm bảo chọn lại account
      final account = await _googleSignIn.signIn();
      if (account == null) return; // User huỷ

      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Không lấy được Google token')),
          );
        }
        return;
      }

      final success = await ref
          .read(authNotifierProvider.notifier)
          .googleLogin(idToken);

      if (!mounted) return;

      if (success) {
        context.go('/home');
      } else {
        final errorMsg = ref.read(authNotifierProvider).errorMessage;
        if (errorMsg == 'ROLE_REQUIRED') {
          // User mới, cần chọn role
          setState(() {
            _pendingGoogleCredential = idToken;
            _selectedGoogleRole = 'STUDENT';
          });
          _showRolePickerDialog();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi Google Sign-In: $e')),
        );
      }
    }
  }

  Future<void> _completeGoogleLoginWithRole() async {
    if (_pendingGoogleCredential == null) return;

    final success = await ref
        .read(authNotifierProvider.notifier)
        .googleLogin(_pendingGoogleCredential!, role: _selectedGoogleRole);

    if (!mounted) return;
    if (success) {
      setState(() => _pendingGoogleCredential = null);
      context.go('/home');
    }
  }

  void _showRolePickerDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Bạn muốn dùng TaskHub với vai trò nào?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Google đã xác thực thành công. Chọn vai trò để tạo tài khoản.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              _RoleCard(
                label: 'Nhà tuyển dụng',
                description: 'Đăng việc và tìm ứng viên',
                icon: Icons.work_outline_rounded,
                isSelected: _selectedGoogleRole == 'HIRER',
                onTap: () => setDialogState(() => _selectedGoogleRole = 'HIRER'),
              ),
              const SizedBox(height: 12),
              _RoleCard(
                label: 'Sinh viên',
                description: 'Tìm việc và nhận thu nhập',
                icon: Icons.school_outlined,
                isSelected: _selectedGoogleRole == 'STUDENT',
                onTap: () => setDialogState(() => _selectedGoogleRole = 'STUDENT'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                setState(() => _pendingGoogleCredential = null);
              },
              child: const Text('Huỷ'),
            ),
            Consumer(builder: (context, ref, _) {
              final isLoading = ref.watch(authNotifierProvider).isLoading;
              return ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () {
                        Navigator.pop(ctx);
                        _completeGoogleLoginWithRole();
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Tiếp tục'),
              );
            }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      body: LoadingOverlay(
        isLoading: authState.isLoading,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 48),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF059669),
                                Color(0xFF0D9488),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF059669).withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.bolt,
                            size: 24,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        RichText(
                          text: const TextSpan(
                            style: TextStyle(
                              fontSize: 32,
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
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Đăng nhập để tiếp tục',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 36),

                  // ── Google Sign-In Button ──
                  OutlinedButton.icon(
                    onPressed: authState.isLoading ? null : _handleGoogleSignIn,
                    icon: Image.network(
                      'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                      height: 20,
                      width: 20,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.g_mobiledata, size: 20),
                    ),
                    label: const Text(
                      'Đăng nhập với Google',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      foregroundColor: AppTheme.textPrimary,
                      backgroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Divider ──
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey[300])),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'hoặc dùng email',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey[300])),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Tab Email / Phone ──
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() { _loginByPhone = false; }),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: !_loginByPhone ? AppTheme.primary : Colors.grey[300]!,
                                  width: 2,
                                ),
                              ),
                            ),
                            child: Text(
                              'Email',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: !_loginByPhone ? FontWeight.bold : FontWeight.normal,
                                color: !_loginByPhone ? AppTheme.primary : Colors.grey[600],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() { _loginByPhone = true; }),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: _loginByPhone ? AppTheme.primary : Colors.grey[300]!,
                                  width: 2,
                                ),
                              ),
                            ),
                            child: Text(
                              'Số điện thoại',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: _loginByPhone ? FontWeight.bold : FontWeight.normal,
                                color: _loginByPhone ? AppTheme.primary : Colors.grey[600],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  if (authState.isError && authState.errorMessage != null && authState.errorMessage != 'ROLE_REQUIRED')
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline,
                              color: AppTheme.error, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              authState.errorMessage!,
                              style: const TextStyle(color: AppTheme.error),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close,
                                color: AppTheme.error, size: 18),
                            onPressed: () => ref
                                .read(authNotifierProvider.notifier)
                                .clearError(),
                          ),
                        ],
                      ),
                    ),
                  if (!_loginByPhone)
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập email của bạn';
                        }
                        if (!value.contains('@')) {
                          return 'Vui lòng nhập email hợp lệ';
                        }
                        return null;
                      },
                    )
                  else
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Số điện thoại',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập số điện thoại của bạn';
                        }
                        return null;
                      },
                    ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _login(),
                    decoration: InputDecoration(
                      labelText: 'Mật khẩu',
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập mật khẩu của bạn';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => context.go('/forgot-password'),
                      child: const Text('Quên mật khẩu?'),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: authState.isLoading ? null : _login,
                    child: authState.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Đăng nhập'),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Chưa có tài khoản? ",
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      TextButton(
                        onPressed: () => context.go('/register'),
                        child: const Text('Đăng ký'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget card chọn role
class _RoleCard extends StatelessWidget {
  final String label;
  final String description;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.label,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppTheme.primary : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
          color: isSelected
              ? AppTheme.primary.withOpacity(0.05)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(icon,
                color: isSelected ? AppTheme.primary : Colors.grey[600],
                size: 28),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? AppTheme.primary : AppTheme.textPrimary,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
