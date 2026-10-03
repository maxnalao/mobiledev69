import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/models/transaction_kind.dart';
import '../../domain/models/transaction_model.dart';
import 'confirm_delete_dialog.dart';

class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const TransactionTile({super.key, required this.transaction, required this.onTap, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.kind == TransactionKind.income;
    final color = isIncome ? AppColors.gold : AppColors.clay;
    final currency = NumberFormat.currency(locale: 'th_TH', symbol: '฿', decimalDigits: 0);

    return Dismissible(
      key: ValueKey(transaction.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(color: AppColors.clay, borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      confirmDismiss: (_) => showConfirmDeleteDialog(context),
      onDismissed: (_) => onDelete(),
      child: Card(
        margin: EdgeInsets.zero,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
                  child: Icon(isIncome ? Icons.savings_rounded : Icons.shopping_bag_outlined, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(transaction.categoryName ?? (isIncome ? 'รายรับทั่วไป' : 'รายจ่ายทั่วไป'), style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 2),
                      Text(
                        transaction.note.isEmpty ? DateFormat('d MMM y', 'th').format(transaction.occurredOn) : transaction.note,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Text((isIncome ? '+' : '-') + currency.format(transaction.amount), style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 15)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}