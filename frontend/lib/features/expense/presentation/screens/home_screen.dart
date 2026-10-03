import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_viewmodel.dart';
import '../../../auth/presentation/auth_viewmodel.dart';
import '../viewmodels/transaction_viewmodel.dart';
import '../widgets/transaction_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<TransactionViewModel>().load());
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TransactionViewModel>();
    final themeViewModel = context.watch<ThemeViewModel>();
    final currency = NumberFormat.currency(locale: 'th_TH', symbol: '฿', decimalDigits: 0);
    final balance = viewModel.totalIncome - viewModel.totalExpense;

    if (viewModel.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(viewModel.errorMessage!)));
      });
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: viewModel.load,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 0,
              title: const Text('รายรับ-รายจ่าย'),
              expandedHeight: 260,
              flexibleSpace: FlexibleSpaceBar(
                background: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 48, 20, 16),
                  child: _BalanceCard(
                    balance: balance,
                    income: viewModel.totalIncome,
                    expense: viewModel.totalExpense,
                    currency: currency,
                    onIncomeTap: () => context.push('/income'),
                    onExpenseTap: () => context.push('/expense'),
                  ),
                ),
              ),
              actions: [
                IconButton(tooltip: 'สรุปภาพรวม', icon: const Icon(Icons.pie_chart_outline_rounded), onPressed: () => context.push('/summary')),
                IconButton(
                  tooltip: themeViewModel.mode == ThemeMode.dark ? 'โหมดสว่าง' : 'โหมดมืด',
                  icon: Icon(themeViewModel.mode == ThemeMode.dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
                  onPressed: () => themeViewModel.toggleDarkMode(themeViewModel.mode != ThemeMode.dark),
                ),
                IconButton(tooltip: 'ออกจากระบบ', icon: const Icon(Icons.logout_rounded), onPressed: () => context.read<AuthViewModel>().logout()),
              ],
            ),
            if (viewModel.isLoading)
              const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
            else if (viewModel.transactions.isEmpty)
              SliverFillRemaining(hasScrollBody: false, child: _EmptyState())
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                sliver: SliverList.separated(
                  itemCount: viewModel.transactions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final transaction = viewModel.transactions[index];
                    return TransactionTile(
                      transaction: transaction,
                      onTap: () => context.push('/transactions/${transaction.id}', extra: transaction),
                      onDelete: () => viewModel.remove(transaction.id!),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/transactions/new'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('เพิ่มรายการ'),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final double balance;
  final double income;
  final double expense;
  final NumberFormat currency;
  final VoidCallback onIncomeTap;
  final VoidCallback onExpenseTap;

  const _BalanceCard({
    required this.balance,
    required this.income,
    required this.expense,
    required this.currency,
    required this.onIncomeTap,
    required this.onExpenseTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.jade, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ยอดคงเหลือ', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 4),
          Text(currency.format(balance), style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w700)),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: onIncomeTap,
                  child: _MiniStat(label: 'รายรับ', value: currency.format(income), color: AppColors.gold, icon: Icons.arrow_downward_rounded),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: onExpenseTap,
                  child: _MiniStat(label: 'รายจ่าย', value: currency.format(expense), color: Colors.white, icon: Icons.arrow_upward_rounded),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _MiniStat({required this.label, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_rounded, size: 56, color: AppColors.jade.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text('ยังไม่มีรายการ', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'แตะปุ่ม "เพิ่มรายการ" ด้านล่างเพื่อเริ่มบันทึก',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6)),
            ),
          ],
        ),
      ),
    );
  }
}