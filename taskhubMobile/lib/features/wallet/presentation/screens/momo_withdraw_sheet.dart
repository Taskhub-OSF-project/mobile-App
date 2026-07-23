import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../providers.dart';

/// Bottom sheet rút tiền từ ví TaskHub về ví MoMo.
class MomoWithdrawSheet extends ConsumerStatefulWidget {
  final double currentBalance;
  final VoidCallback? onSuccess;

  const MomoWithdrawSheet({
    super.key,
    required this.currentBalance,
    this.onSuccess,
  });

  @override
  ConsumerState<MomoWithdrawSheet> createState() => _MomoWithdrawSheetState();
}

class _MomoWithdrawSheetState extends ConsumerState<MomoWithdrawSheet> {
  final _amountController = TextEditingController();
  final _phoneController  = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _vndFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '');

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _amountController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(
        _amountController.text.replaceAll('.', '').replaceAll(',', ''));
    final phone = _phoneController.text.trim();

    if (amount == null || amount <= 0) {
      setState(() => _errorMessage = 'Số tiền không hợp lệ');
      return;
    }

    setState(() { _isLoading = true; _errorMessage = null; });

    final repo = ref.read(momoRepositoryProvider);
    final result = await repo.requestWithdrawal(amount: amount, phone: phone);

    if (!mounted) return;
    setState(() => _isLoading = false);

    result.when(
      success: (response) {
        if (response.isSuccess) {
          widget.onSuccess?.call();
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(response.message ?? 'Rút tiền thành công!'),
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
          ));
        } else {
          setState(() => _errorMessage = response.message ?? 'Rút tiền thất bại');
        }
      },
      failure: (error) {
        setState(() => _errorMessage = error.message);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppTheme.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFAE2070).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(Icons.arrow_upward_rounded,
                        color: Color(0xFFAE2070), size: 22),
                  ),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Rút tiền về ví MoMo', style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    )),
                    Text('Nhận tiền trong vài phút', style: TextStyle(
                      fontSize: 13, color: AppTheme.textSecondary,
                    )),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Balance info
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.surfaceElevated,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Số dư khả dụng',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                  Text(
                    '${_vndFormat.format(widget.currentBalance)} VND',
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Amount field
            const Text('Số tiền rút', style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textSecondary,
            )),
            const SizedBox(height: 8),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              decoration: const InputDecoration(
                hintText: 'Nhập số tiền...',
                suffixText: 'VND',
                suffixStyle: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Vui lòng nhập số tiền';
                final amount = double.tryParse(v.replaceAll('.', '').replaceAll(',', ''));
                if (amount == null || amount <= 0) return 'Số tiền không hợp lệ';
                if (amount < 10000) return 'Tối thiểu 10,000 VND';
                if (amount > 10000000) return 'Tối đa 10,000,000 VND';
                if (amount > widget.currentBalance) return 'Số dư không đủ';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Phone field
            const Text('Số điện thoại MoMo', style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textSecondary,
            )),
            const SizedBox(height: 8),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              maxLength: 10,
              decoration: const InputDecoration(
                hintText: 'VD: 0901234567',
                prefixIcon: Icon(Icons.phone_outlined, size: 18, color: AppTheme.textTertiary),
                counterText: '',
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Vui lòng nhập SĐT MoMo';
                if (!RegExp(r'^0[35789][0-9]{8}$').hasMatch(v.trim())) {
                  return 'SĐT không hợp lệ (VD: 0901234567)';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),

            // Disclaimer
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.warning.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.warning.withOpacity(0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, color: AppTheme.warning, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tiền sẽ được chuyển về số điện thoại MoMo bạn nhập. '
                      'Vui lòng kiểm tra kỹ trước khi xác nhận.',
                      style: TextStyle(
                        color: AppTheme.warning.withOpacity(0.9),
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.error.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppTheme.error, size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_errorMessage!,
                      style: const TextStyle(color: AppTheme.error, fontSize: 13))),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFAE2070),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFFAE2070).withOpacity(0.5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Xác nhận rút tiền',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
