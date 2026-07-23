import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../providers.dart';
import '../../data/models/momo_models.dart';

/// Bottom sheet nạp tiền qua MoMo.
/// Hiển thị các mức tiền preset và input tùy chỉnh,
/// sau đó mở deeplink app MoMo và polling trạng thái khi quay lại.
class MomoDepositSheet extends ConsumerStatefulWidget {
  final VoidCallback? onSuccess;

  const MomoDepositSheet({super.key, this.onSuccess});

  @override
  ConsumerState<MomoDepositSheet> createState() => _MomoDepositSheetState();
}

class _MomoDepositSheetState extends ConsumerState<MomoDepositSheet> {
  static const List<int> _presets = [50000, 100000, 200000, 500000, 1000000, 2000000];

  final _amountController = TextEditingController();
  final _vndFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '');

  int? _selectedPreset;
  bool _isLoading = false;
  String? _errorMessage;
  String? _pendingOrderId;
  bool _waitingForPayment = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  double? get _enteredAmount {
    if (_selectedPreset != null) return _selectedPreset!.toDouble();
    final raw = _amountController.text.replaceAll('.', '').replaceAll(',', '');
    return double.tryParse(raw);
  }

  Future<void> _onPresetTap(int amount) async {
    setState(() {
      _selectedPreset = amount;
      _amountController.clear();
      _errorMessage = null;
    });
  }

  Future<void> _submit() async {
    final amount = _enteredAmount;
    if (amount == null || amount <= 0) {
      setState(() => _errorMessage = 'Vui lòng nhập hoặc chọn số tiền');
      return;
    }
    if (amount < 10000) {
      setState(() => _errorMessage = 'Số tiền tối thiểu là 10,000 VND');
      return;
    }
    if (amount > 50000000) {
      setState(() => _errorMessage = 'Số tiền tối đa là 50,000,000 VND');
      return;
    }

    setState(() { _isLoading = true; _errorMessage = null; });

    final repo = ref.read(momoRepositoryProvider);
    final result = await repo.createDepositOrder(amount: amount);

    if (!mounted) return;

    result.when(
      success: (order) async {
        setState(() { _isLoading = false; _pendingOrderId = order.orderId; });
        await _launchMoMo(order);
      },
      failure: (error) {
        setState(() {
          _isLoading = false;
          _errorMessage = error.message;
        });
      },
    );
  }

  Future<void> _launchMoMo(MomoCreateOrderResponse order) async {
    final url = order.launchUrl;
    if (url == null || url.isEmpty) {
      setState(() => _errorMessage = 'Không lấy được link thanh toán MoMo');
      return;
    }

    final uri = Uri.parse(url);
    bool launched = false;

    // Thử deeplink momo:// trước
    if (order.deeplink != null && order.deeplink!.isNotEmpty) {
      try {
        launched = await launchUrl(Uri.parse(order.deeplink!),
            mode: LaunchMode.externalApplication);
      } catch (_) {}
    }

    // Fallback: payUrl (WebView / browser)
    if (!launched && order.payUrl != null && order.payUrl!.isNotEmpty) {
      try {
        launched = await launchUrl(Uri.parse(order.payUrl!),
            mode: LaunchMode.externalApplication);
      } catch (_) {}
    }

    if (!launched) {
      setState(() => _errorMessage = 'Không mở được app MoMo. Hãy cài đặt MoMo và thử lại.');
      return;
    }

    // Hiện hướng dẫn
    setState(() => _waitingForPayment = true);
  }

  Future<void> _checkPaymentStatus() async {
    if (_pendingOrderId == null) return;
    setState(() { _isLoading = true; _errorMessage = null; });

    final repo = ref.read(momoRepositoryProvider);
    final result = await repo.getDepositStatus(_pendingOrderId!);

    if (!mounted) return;
    setState(() => _isLoading = false);

    result.when(
      success: (status) {
        if (status == 'SUCCESS') {
          widget.onSuccess?.call();
          Navigator.of(context).pop(true);
          _showSuccessSnackbar();
        } else if (status == 'PENDING') {
          setState(() => _errorMessage = 'Thanh toán chưa hoàn tất. Vui lòng kiểm tra lại trong app MoMo.');
        } else {
          setState(() => _errorMessage = 'Thanh toán thất bại hoặc đã bị hủy.');
          setState(() => _waitingForPayment = false);
        }
      },
      failure: (error) {
        setState(() => _errorMessage = error.message);
      },
    );
  }

  void _showSuccessSnackbar() {
    final amount = _enteredAmount ?? 0;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('✅ Nạp ${_vndFormat.format(amount)} VND thành công!'),
      backgroundColor: AppTheme.success,
      behavior: SnackBarBehavior.floating,
    ));
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
                  child: Text('M', style: TextStyle(
                    color: Color(0xFFAE2070), fontSize: 22, fontWeight: FontWeight.w800,
                  )),
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nạp tiền qua MoMo', style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary,
                  )),
                  Text('Thanh toán an toàn · Tức thì', style: TextStyle(
                    fontSize: 13, color: AppTheme.textSecondary,
                  )),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          if (!_waitingForPayment) ..._buildDepositForm()
          else ..._buildWaitingState(),

          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
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
          ],
        ],
      ),
    );
  }

  List<Widget> _buildDepositForm() {
    return [
      // Preset amounts grid
      const Text('Chọn số tiền', style: TextStyle(
        fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textSecondary,
      )),
      const SizedBox(height: 12),
      Wrap(
        spacing: 10,
        runSpacing: 10,
        children: _presets.map((amount) {
          final selected = _selectedPreset == amount;
          return GestureDetector(
            onTap: () => _onPresetTap(amount),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: selected ? const Color(0xFFAE2070) : AppTheme.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected ? const Color(0xFFAE2070) : AppTheme.border,
                  width: selected ? 1.5 : 1,
                ),
              ),
              child: Text(
                _formatPreset(amount),
                style: TextStyle(
                  color: selected ? Colors.white : AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          );
        }).toList(),
      ),
      const SizedBox(height: 20),

      // Custom input
      const Text('Hoặc nhập số tiền khác', style: TextStyle(
        fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textSecondary,
      )),
      const SizedBox(height: 8),
      TextField(
        controller: _amountController,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        decoration: const InputDecoration(
          hintText: 'VD: 150000',
          suffixText: 'VND',
          suffixStyle: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
        ),
        onChanged: (_) => setState(() => _selectedPreset = null),
      ),
      const SizedBox(height: 24),

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
              : const Text('Thanh toán qua MoMo',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        ),
      ),
    ];
  }

  List<Widget> _buildWaitingState() {
    return [
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFAE2070).withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFAE2070).withOpacity(0.2)),
        ),
        child: const Column(
          children: [
            Icon(Icons.open_in_new_rounded, color: Color(0xFFAE2070), size: 36),
            SizedBox(height: 12),
            Text('App MoMo đã được mở', style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary,
            )),
            SizedBox(height: 6),
            Text(
              'Hoàn thành thanh toán trong app MoMo,\nsau đó quay lại đây để xác nhận.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.5),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _checkPaymentStatus,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFAE2070),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: _isLoading
              ? const SizedBox(width: 20, height: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Tôi đã thanh toán xong ✓',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        ),
      ),
      const SizedBox(height: 8),
      SizedBox(
        width: double.infinity,
        child: TextButton(
          onPressed: () => setState(() {
            _waitingForPayment = false;
            _pendingOrderId = null;
          }),
          child: const Text('← Quay lại', style: TextStyle(color: AppTheme.textSecondary)),
        ),
      ),
    ];
  }

  String _formatPreset(int amount) {
    if (amount >= 1000000) return '${amount ~/ 1000000}tr';
    if (amount >= 1000) return '${amount ~/ 1000}k';
    return amount.toString();
  }
}
