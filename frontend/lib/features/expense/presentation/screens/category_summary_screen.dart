import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/models/transaction_kind.dart';
import '../../domain/models/transaction_model.dart';
import '../viewmodels/transaction_viewmodel.dart';
import '../widgets/transaction_tile.dart';

/// Shows every transaction of one kind (income or expense), grouped by
/// category with a subtotal per category, plus a grand total at the top.
class CategorySummaryScreen extends StatelessWidget {
  final TransactionKind kind;

  const CategorySummaryScreen({super.key, required this.kind});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TransactionViewModel>();
    final currency = NumberFormat.currency(locale: 'th_TH', symbol: '฿', decimalDigits: 0);
    final isIncome = kind == TransactionKind.income;
    final color = isIncome ? AppColors.gold : AppColors.clay;

    final items = viewModel.transactions.where((t) => t.kind == kind).toList();
    final total = items.fold<double>(0, (sum, t) => sum + t.amount);

    final Map<String, List<TransactionModel>> grouped = {};
    for (final t in items) {
      final key = t.categoryName ?? (isIncome ? 'รายรับทั่วไป' : 'รายจ่ายทั่วไป');
      grouped.putIfAbsent(key, () => []).add(t);
    }
    final categoryNames = grouped.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(title: Text(isIncome ? 'รายรับทั้งหมด' : 'รายจ่ายทั้งหมด')),
      body: items.isEmpty
          ? Center(child: Text(isIncome ? 'ยังไม่มีรายรับ' : 'ยังไม่มีรายจ่าย', style: Theme.of(context).textTheme.bodyMedium))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(isIncome ? 'รายรับรวมทั้งหมด' : 'รายจ่ายรวมทั้งหมด', style: const TextStyle(color: Colors.white70, fontSize: 14)),
                      const SizedBox(height: 4),
                      Text(currency.format(total), style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                for (final categoryName in categoryNames) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(categoryName, style: Theme.of(context).textTheme.titleMedium),
                        Text(
                          currency.format(grouped[categoryName]!.fold<double>(0, (s, t) => s + t.amount)),
                          style: TextStyle(color: color, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  ...grouped[categoryName]!.map(
                    (t) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: TransactionTile(
                        transaction: t,
                        onTap: () => context.push('/transactions/${t.id}'),
                        onDelete: () => viewModel.remove(t.id!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            ),
    );
  }
}