import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/common_widgets.dart';
import '../../../../core/models/api_error.dart';
import '../../data/models/auth_models.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _byPhone = false;
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      if (_byPhone) {
        final success = await ref.read(authNotifierProvider.notifier)
            .requestPhoneOtp(_phoneController.text.trim(), 'RECOVERY');
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('OTP đã được gửi đến số điện thoại của bạn.')),
          );
          context.go('/otp-verify', extra: {
            'phone': _phoneController.text.trim(),
            'type': 'RECOVERY',
          });
        }
      } else {
        final repo = ref.read(authRepositoryProvider);
        final res = await repo.forgotPassword(ForgotPasswordRequest(email: _emailController.text.trim()));
        res.when(
          success: (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Email khôi phục đã được gửi. Kiểm tra hộp thư.')),
            );
            context.go('/login');
          },
          failure: (err) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text((err as ApiError).message), backgroundColor: AppTheme.error),
            );
          },
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quên mật khẩu'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: LoadingOverlay(
        isLoading: _loading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                Text(
                  'Khôi phục tài khoản',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Chọn kênh để nhận mã khôi phục mật khẩu.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _byPhone = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: !_byPhone ? AppTheme.primary : Colors.grey[300]!,
                                width: 2,
                              ),
                            ),
                          ),
                          child: Text(
                            'Email',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: !_byPhone ? FontWeight.bold : FontWeight.normal,
                              color: !_byPhone ? AppTheme.primary : Colors.grey[600],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _byPhone = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: _byPhone ? AppTheme.primary : Colors.grey[300]!,
                                width: 2,
                              ),
                            ),
                          ),
                          child: Text(
                            'SMS',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: _byPhone ? FontWeight.bold : FontWeight.normal,
                              color: _byPhone ? AppTheme.primary : Colors.grey[600],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (!_byPhone)
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Nhập email';
                      if (!value.contains('@')) return 'Email không hợp lệ';
                      return null;
                    },
                  )
                else
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Số điện thoại',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Nhập số điện thoại';
                      return null;
                    },
                  ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: Text(_loading ? 'Đang gửi...' : 'Gửi mã khôi phục'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
