import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../wallet/data/models/wallet_models.dart';
import '../../../../shared/widgets/common_widgets.dart';
import 'sepay_deposit_sheet.dart';
import 'payout_withdraw_sheet.dart';

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
  List<PayoutRequestResponse> _payoutRequests = [];
  bool _isLoading = true;
  String? _error;
  double _escrowBalance = 0;

  final _vndFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
    final payoutResult = await repo.getMyPayoutRequests();
    
    double computedEscrow = 0;
    final user = ref.read(currentUserProvider);
    if (user != null && user.isHirer) {
      final taskRepo = ref.read(taskRepositoryProvider);
      final tasksResult = await taskRepo.getMyTasks(size: 1000);
      if (tasksResult.isSuccess) {
        final allTasks = tasksResult.data?.content ?? [];
        final escrowedStatuses = ["ESCROW_FUNDED", "ACTIVE", "IN_PROGRESS", "SUBMITTED", "DISPUTED"];
        for (var t in allTasks) {
          if (escrowedStatuses.contains(t.status)) {
            computedEscrow += t.budget * 1.05;
          }
        }
      }
    }

    if (mounted) {
      setState(() {
        _wallet = balanceResult.data;
        _escrowBalance = computedEscrow;
        _transactions = txResult.data?.content ?? [];
        _payoutRequests = payoutResult.data?.content ?? [];
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
            Tab(text: 'Yêu cầu rút'),
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
                    _buildPayouts(),
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
                    colors: [
                      Color(0xFF10B981), // emerald-500
                      Color(0xFF059669), // emerald-600
                      Color(0xFF047857), // emerald-700
                    ],
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
                    if (_escrowBalance > 0) ...[
                      const SizedBox(height: 12),
                      const Text('Đang giữ ký quỹ (Escrow)',
                          style: TextStyle(color: Colors.white70, fontSize: 14)),
                      const SizedBox(height: 4),
                      Text(
                        '${_vndFormat.format(_escrowBalance)} VND',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _showDepositSheet(),
                            icon: const Icon(Icons.qr_code, size: 18),
                            label: const Text('Nạp tiền'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF00513D),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _showWithdrawSheet(),
                            icon: const Icon(Icons.arrow_upward_rounded, size: 18),
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

  Widget _buildPayouts() {
    if (_payoutRequests.isEmpty) {
      return const EmptyState(
        icon: Icons.account_balance_wallet_outlined,
        title: 'Chưa có đơn rút tiền',
        subtitle: 'Các đơn yêu cầu rút tiền sẽ hiển thị tại đây.',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _payoutRequests.length,
        itemBuilder: (context, index) {
          final pr = _payoutRequests[index];
          final isPending = pr.status == 'PENDING';
          final isCompleted = pr.status == 'COMPLETED';

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isPending ? Icons.access_time_filled : isCompleted ? Icons.check_circle : Icons.cancel,
                            color: isPending ? const Color(0xFF8A5B00) : isCompleted ? AppTheme.success : AppTheme.error,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text('#PR-${pr.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isPending ? const Color(0xFFFFF4D6) : isCompleted ? const Color(0xFFE6F4EA) : const Color(0xFFFDECEA),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          pr.statusLabel,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isPending ? const Color(0xFF8A5B00) : isCompleted ? const Color(0xFF237A45) : const Color(0xFFB42318),
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${pr.bankCode} - ${pr.accountNumber} (${pr.accountName})',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF52645D)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${_vndFormat.format(pr.amount)} ₫',
                        style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF031D31)),
                      ),
                    ],
                  ),
                  if (pr.adminNote != null && pr.adminNote!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F7F5),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFD5E2DB)),
                      ),
                      child: Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(text: 'Phản hồi: ', style: TextStyle(fontWeight: FontWeight.bold)),
                            TextSpan(text: pr.adminNote),
                          ],
                        ),
                        style: const TextStyle(fontSize: 11, color: Color(0xFF40544B)),
                      ),
                    )
                  ],
                  const SizedBox(height: 8),
                  Text(
                    pr.createdAt.split('T').join(' ').substring(0, 16),
                    style: const TextStyle(fontSize: 10, color: Color(0xFF84948D)),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showDepositSheet() async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SepayDepositSheet(),
    );
    if (result == true && mounted) {
      _loadData();
    }
  }

  Future<void> _showWithdrawSheet() async {
    final balance = _wallet?.balance ?? 0;
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PayoutWithdrawSheet(
        currentBalance: balance,
      ),
    );
    if (result == true && mounted) {
      _loadData();
    }
  }
}
