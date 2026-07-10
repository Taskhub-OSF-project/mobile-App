import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/common_widgets.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  final String phone;
  final String type;

  const OtpVerificationScreen({
    super.key,
    required this.phone,
    required this.type,
  });

  @override
  ConsumerState<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _loading = false;
  int _countdown = 300; // 5 minutes
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    for (var c in _controllers) c.dispose();
    for (var n in _focusNodes) n.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_countdown > 0) _countdown--;
        });
      }
    });
  }

  String get _otpCode => _controllers.map((c) => c.text).join();

  void _onKeyChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (_otpCode.length == 6) {
      _verifyOtp();
    }
    setState(() {});
  }



  Future<void> _verifyOtp() async {
    if (_otpCode.length != 6) return;
    setState(() => _loading = true);

    try {
      final success = await ref.read(authNotifierProvider.notifier)
          .resetPasswordWithOtp(widget.phone, _otpCode, 'DUMMY_PLACEHOLDER');

      if (success && mounted) {
        context.go('/reset-password', extra: {
          'phone': widget.phone,
          'code': _otpCode,
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resend() async {
    if (_countdown > 0) return;
    setState(() => _loading = true);
    try {
      await ref.read(authNotifierProvider.notifier)
          .requestPhoneOtp(widget.phone, widget.type);
      setState(() => _countdown = 300);
      _timer?.cancel();
      _startCountdown();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã gửi lại mã OTP.')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String get _formattedCountdown {
    final m = _countdown ~/ 60;
    final s = _countdown % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xác thực OTP'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: LoadingOverlay(
        isLoading: _loading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Text(
                'Nhập mã xác thực',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Mã OTP 6 chữ số đã được gửi đến\n${widget.phone}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (index) {
                  return Container(
                    width: 48,
                    height: 56,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    child: KeyboardListener(
                      focusNode: _focusNodes[index],
                      onKeyEvent: (event) {
                        if (event is KeyDownEvent &&
                            event.logicalKey == LogicalKeyboardKey.backspace &&
                            _controllers[index].text.isEmpty &&
                            index > 0) {
                          _focusNodes[index - 1].requestFocus();
                          _controllers[index - 1].text = '';
                        }
                      },
                      child: TextField(
                        controller: _controllers[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        obscureText: true,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: _controllers[index].text.isNotEmpty
                              ? AppTheme.primary.withValues(alpha: 0.1)
                              : Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: _controllers[index].text.isNotEmpty
                                  ? AppTheme.primary
                                  : Colors.grey[300]!,
                              width: _controllers[index].text.isNotEmpty ? 2 : 1,
                            ),
                          ),
                        ),
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        onChanged: (value) => _onKeyChanged(index, value),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              Text(
                'Mã có hiệu lực trong: $_formattedCountdown',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              if (_countdown == 0)
                Center(
                  child: TextButton(
                    onPressed: _loading ? null : _resend,
                    child: const Text('Gửi lại mã OTP'),
                  ),
                )
              else
                const SizedBox(height: 40),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _otpCode.length == 6 && !_loading ? _verifyOtp : null,
                child: const Text('Xác thực'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
