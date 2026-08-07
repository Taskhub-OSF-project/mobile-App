import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskhub_mobile/core/theme/app_theme.dart';
import 'package:taskhub_mobile/providers.dart';
import 'package:intl/intl.dart';

class PayoutWithdrawSheet extends ConsumerStatefulWidget {
  final double currentBalance;

  const PayoutWithdrawSheet({super.key, required this.currentBalance});

  @override
  ConsumerState<PayoutWithdrawSheet> createState() => _PayoutWithdrawSheetState();
}

class _PayoutWithdrawSheetState extends ConsumerState<PayoutWithdrawSheet> {
  final _amountController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _accountNameController = TextEditingController();

  final List<String> _banks = [
    "MB Bank",
    "Vietcombank",
    "Techcombank",
    "ACB",
    "BIDV",
    "VietinBank"
  ];
  String _selectedBank = "MB Bank";
  bool _loading = false;

  @override
  void dispose() {
    _amountController.dispose();
    _accountNumberController.dispose();
    _accountNameController.dispose();
    super.dispose();
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    return formatter.format(amount);
  }

  Future<void> _submit() async {
    final amountStr = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final amount = double.tryParse(amountStr) ?? 0;
    final accountNumber = _accountNumberController.text.trim();
    final accountName = _accountNameController.text.trim().toUpperCase();

    if (amount < 50000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Số tiền rút tối thiểu là 50.000₫.')),
      );
      return;
    }
    if (amount > widget.currentBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Số dư khả dụng không đủ.')),
      );
      return;
    }
    if (accountNumber.isEmpty || accountName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đầy đủ STK và Tên chủ TK.')),
      );
      return;
    }

    setState(() {
      _loading = true;
    });

    final repo = ref.read(walletRepositoryProvider);
    final res = await repo.createPayoutRequest(
      amount: amount,
      bankCode: _selectedBank,
      accountNumber: accountNumber,
      accountName: accountName,
    );

    if (mounted) {
      setState(() {
        _loading = false;
      });
      if (res.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã tạo yêu cầu rút ${_formatCurrency(amount)} thành công!')),
        );
        Navigator.pop(context, true); // Return true to refresh data
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res.error?.toString() ?? 'Lỗi khi tạo yêu cầu rút tiền')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Rút tiền / Hoàn số dư',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEDF6F1),
                border: Border.all(color: AppTheme.primary),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.account_balance, color: AppTheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Chuyển khoản Ngân hàng Trực Tiếp', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text('Yêu cầu rút của bạn sẽ được Admin xác thực và chuyển khoản VietQR trong thời gian sớm nhất.', style: TextStyle(color: Color(0xFF52645D), fontSize: 11)),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Số tiền rút (VND)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text('Khả dụng: ${_formatCurrency(widget.currentBalance)}', style: const TextStyle(fontSize: 12, color: Color(0xFF52645D))),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[50],
                hintText: '500.000',
                suffixText: '₫',
                suffixStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.primary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Ngân hàng', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedBank,
                  isExpanded: true,
                  items: _banks.map((String bank) {
                    return DropdownMenuItem<String>(
                      value: bank,
                      child: Text(bank, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedBank = newValue!;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Số tài khoản', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            TextField(
              controller: _accountNumberController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.black),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[50],
                hintText: 'Nhập số tài khoản ngân hàng',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.primary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Tên chủ tài khoản', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            TextField(
              controller: _accountNameController,
              style: const TextStyle(color: Colors.black),
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[50],
                hintText: 'NGUYEN VAN A',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.primary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text(
                      'Rút tiền về tài khoản',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
