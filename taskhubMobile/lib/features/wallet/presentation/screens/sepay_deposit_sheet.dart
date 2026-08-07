import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskhub_mobile/core/theme/app_theme.dart';
import 'package:taskhub_mobile/providers.dart';
import 'package:intl/intl.dart';

import '../../data/models/wallet_models.dart';

class SepayDepositSheet extends ConsumerStatefulWidget {
  const SepayDepositSheet({super.key});

  @override
  ConsumerState<SepayDepositSheet> createState() => _SepayDepositSheetState();
}

class _SepayDepositSheetState extends ConsumerState<SepayDepositSheet> {
  final _amountController = TextEditingController(text: '1000000');
  double _amount = 1000000;
  bool _loading = true;
  SepayBankConfig? _config;

  final _presets = [500000.0, 1000000.0, 2000000.0, 5000000.0];

  @override
  void initState() {
    super.initState();
    _loadConfig();
    _amountController.addListener(() {
      final val = double.tryParse(_amountController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      setState(() {
        _amount = val;
      });
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadConfig() async {
    final repo = ref.read(walletRepositoryProvider);
    final res = await repo.getSepayConfig();
    if (res.isSuccess) {
      setState(() {
        _config = res.data;
        _loading = false;
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lỗi tải cấu hình SePay')),
        );
        Navigator.pop(context);
      }
    }
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã sao chép $label')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final addInfo = 'THTT ${user?.id ?? "USER"}';
    String qrUrl = '';
    
    if (_config != null && _amount > 0) {
      final bankCode = _config!.bankCode;
      final bankAccount = _config!.bankAccount;
      final template = _config!.qrTemplate.isNotEmpty ? _config!.qrTemplate : 'compact';
      qrUrl = 'https://img.vietqr.io/image/$bankCode-$bankAccount-$template.png'
          '?amount=${_amount.toInt()}'
          '&addInfo=${Uri.encodeComponent(addInfo)}'
          '&accountName=${Uri.encodeComponent(_config!.accountName)}';
    }

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
      child: _loading
          ? const SizedBox(
              height: 300,
              child: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
            )
          : SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Nạp tiền vào ví',
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
                  const Text(
                    'Số tiền (VND)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _presets.map((preset) {
                      final isSelected = _amount == preset;
                      final label = preset >= 1000000 
                          ? '${(preset / 1000000).toInt()}M' 
                          : '${(preset / 1000).toInt()}k';
                      return InkWell(
                        onTap: () {
                          _amountController.text = preset.toInt().toString();
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.primary.withOpacity(0.1) : Colors.white,
                            border: Border.all(
                              color: isSelected ? AppTheme.primary : Colors.grey[300]!,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            label,
                            style: TextStyle(
                              color: isSelected ? AppTheme.primary : Colors.grey[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FBFA),
                      border: Border.all(color: const Color(0xFFB9CEC3)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.qr_code, color: AppTheme.primary, size: 20),
                            SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'Quét mã VietQR tự động Nạp Tiền',
                                style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (_amount > 0 && qrUrl.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFD5E2DB)),
                            ),
                            child: Image.network(qrUrl, width: 160, height: 160, fit: BoxFit.contain),
                          )
                        else
                          Container(
                            width: 160,
                            height: 160,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFD5E2DB)),
                            ),
                            child: const Center(
                              child: Text('Nhập số tiền hợp lệ\nđể hiển thị QR', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 12)),
                            ),
                          ),
                        const SizedBox(height: 16),
                        _buildInfoRow('Ngân hàng', _config?.bankName ?? ''),
                        const Divider(height: 24, color: Color(0xFFEDF6F1)),
                        _buildInfoRowWithCopy('Số tài khoản', _config?.bankAccount ?? ''),
                        const Divider(height: 24, color: Color(0xFFEDF6F1)),
                        _buildInfoRow('Chủ tài khoản', _config?.accountName ?? '', isUppercase: true),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFDF0),
                            border: Border.all(color: const Color(0xFFF5E6A3)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Nội dung CK', style: TextStyle(color: Color(0xFF8A5B00), fontWeight: FontWeight.bold, fontSize: 12)),
                              Row(
                                children: [
                                  Text(
                                    addInfo,
                                    style: const TextStyle(color: Color(0xFF8A5B00), fontWeight: FontWeight.w900, fontSize: 14),
                                  ),
                                  const SizedBox(width: 8),
                                  InkWell(
                                    onTap: () => _copyToClipboard(addInfo, 'Nội dung CK'),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF8A5B00),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text('Copy', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '* Lưu ý: Bắt buộc ghi đúng Nội dung chuyển khoản ở trên để hệ thống tự động nhận diện và cộng tiền.',
                          style: TextStyle(color: Color(0xFF8A5B00), fontSize: 10, fontStyle: FontStyle.italic),
                          textAlign: TextAlign.center,
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isUppercase = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF52645D), fontWeight: FontWeight.w500, fontSize: 13)),
        Text(isUppercase ? value.toUpperCase() : value, style: const TextStyle(color: Color(0xFF031D31), fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }

  Widget _buildInfoRowWithCopy(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF52645D), fontWeight: FontWeight.w500, fontSize: 13)),
        Row(
          children: [
            Text(value, style: const TextStyle(color: Color(0xFF031D31), fontWeight: FontWeight.w900, fontSize: 14)),
            const SizedBox(width: 8),
            InkWell(
              onTap: () => _copyToClipboard(value, label),
              child: const Icon(Icons.copy, size: 16, color: AppTheme.primary),
            )
          ],
        )
      ],
    );
  }
}
