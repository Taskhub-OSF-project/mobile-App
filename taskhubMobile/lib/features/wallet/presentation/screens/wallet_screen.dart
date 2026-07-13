import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../wallet/data/models/wallet_models.dart';
import '../../../../shared/widgets/common_widgets.dart';

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  WalletResponse? _wallet;
  List<WalletTransactionResponse> _transactions = [];
  bool _isLoading = true;
  String? _error;
  int _page = 0;
  bool _hasMore = true;

  final _vndFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final repo = ref.read(walletRepositoryProvider);
    final balanceResult = await repo.getBalance();
    final txResult = await repo.getTransactionsPaged();

    if (mounted) {
      setState(() {
        _wallet = balanceResult.data;
        _transactions = txResult.data?.content ?? [];
        _hasMore = txResult.data?.hasNext ?? false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ví'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Tổng quan'),
            Tab(text: 'Giao dịch'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? ErrorDisplay(message: _error!, onRetry: _loadData)
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverview(),
                    _buildTransactions(),
                  ],
                ),
    );
  }

  Widget _buildOverview() {
    final balance = _wallet?.balance ?? 0;

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primary, AppTheme.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Số dư khả dụng',
                        style: TextStyle(color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 8),
                    Text(
                      '${_vndFormat.format(balance)} VND',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _showAmountDialog(true),
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Nạp tiền'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppTheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _showAmountDialog(false),
                            icon: const Icon(Icons.remove, size: 18),
                            label: const Text('Rút tiền'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Info card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Phí nền tảng: 5% mỗi công việc',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text(
                      'Tiền được giữ an toàn (escrow) cho đến khi hoàn thành công việc.',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactions() {
    if (_transactions.isEmpty) {
      return const EmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'Chưa có giao dịch nào',
        subtitle: 'Lịch sử giao dịch của bạn sẽ hiển thị ở đây',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _transactions.length,
        itemBuilder: (context, index) {
          final tx = _transactions[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: tx.isPositive
                    ? AppTheme.success.withOpacity(0.1)
                    : AppTheme.error.withOpacity(0.1),
                child: Icon(
                  tx.isPositive ? Icons.arrow_downward : Icons.arrow_upward,
                  color: tx.isPositive ? AppTheme.success : AppTheme.error,
                  size: 20,
                ),
              ),
              title: Text(tx.typeLabel),
              subtitle: Text(tx.createdAt.split('T').first),
              trailing: Text(
                '${tx.isPositive ? '+' : '-'}${_vndFormat.format(tx.amount.abs())} VND',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: tx.isPositive ? AppTheme.success : AppTheme.error,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showAmountDialog(bool isDeposit) async {
    final controller = TextEditingController();
    final result = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isDeposit ? 'Nạp tiền' : 'Rút tiền'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Số tiền (VND)',
            hintText: 'VD: 100000',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(controller.text);
              Navigator.pop(context, amount);
            },
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );

    if (result != null && result > 0 && mounted) {
      final repo = ref.read(walletRepositoryProvider);
      final apiResult = isDeposit
          ? await repo.deposit(result)
          : await repo.withdraw(result);

      if (apiResult.isSuccess && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${isDeposit ? 'Nạp' : 'Rút'} ${_vndFormat.format(result)} VND thành công!'),
          ),
        );
        _loadData();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(apiResult.error?.message ?? 'Giao dịch thất bại')),
        );
      }
    }
  }
}
