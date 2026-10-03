import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/models/transaction_kind.dart';
import '../../domain/models/transaction_model.dart';
import '../viewmodels/transaction_viewmodel.dart';
import '../widgets/confirm_delete_dialog.dart';

/// Read (Detail view): shows one transaction, with Edit and Delete actions.
class TransactionDetailScreen extends StatefulWidget {
  final int id;

  const TransactionDetailScreen({super.key, required this.id});

  @override
  State<TransactionDetailScreen> createState() => _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<TransactionViewModel>();
      if (viewModel.findById(widget.id) == null) viewModel.load();
    });
  }

  Future<void> _delete(TransactionModel transaction) async {
    if (!await showConfirmDeleteDialog(context) || !mounted) return;

    final viewModel = context.read<TransactionViewModel>();
    final success = await viewModel.remove(transaction.id!);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ลบรายการแล้ว')));
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(viewModel.errorMessage ?? 'ลบรายการไม่สำเร็จ')));
      viewModel.clearError();
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TransactionViewModel>();
    final transaction = viewModel.findById(widget.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('รายละเอียดรายการ'),
        actions: [
          if (transaction != null) ...[
            IconButton(
              tooltip: 'แก้ไข',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => context.push('/transactions/${transaction.id}/edit', extra: transaction),
            ),
            IconButton(tooltip: 'ลบ', icon: const Icon(Icons.delete_outline_rounded), onPressed: () => _delete(transaction)),
          ],
        ],
      ),
      body: transaction != null
          ? _DetailBody(transaction: transaction)
          : Center(
              child: viewModel.isLoading
                  ? const CircularProgressIndicator()
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(viewModel.errorMessage ?? 'ไม่พบรายการนี้'),
                        const SizedBox(height: 12),
                        OutlinedButton(onPressed: viewModel.load, child: const Text('ลองใหม่')),
                      ],
                    ),
            ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  final TransactionModel transaction;

  const _DetailBody({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.kind == TransactionKind.income;
    final color = isIncome ? AppColors.gold : AppColors.clay;
    final currency = NumberFormat.currency(locale: 'th_TH', symbol: '฿', decimalDigits: 2);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Center(
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: Icon(isIncome ? Icons.savings_rounded : Icons.shopping_bag_outlined, color: color, size: 36),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            (isIncome ? '+' : '-') + currency.format(transaction.amount),
            style: TextStyle(color: color, fontSize: 32, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 24),
        Card(
          margin: EdgeInsets.zero,
          child: Column(
            children: [
              _DetailRow(icon: Icons.swap_vert_rounded, label: 'ประเภท', value: isIncome ? 'รายรับ' : 'รายจ่าย'),
              _DetailRow(icon: Icons.category_outlined, label: 'หมวดหมู่', value: transaction.categoryName ?? 'ไม่ระบุ'),
              _DetailRow(icon: Icons.event_outlined, label: 'วันที่', value: DateFormat('d MMMM y', 'th').format(transaction.occurredOn)),
              _DetailRow(icon: Icons.notes_rounded, label: 'บันทึกช่วยจำ', value: transaction.note.isEmpty ? '-' : transaction.note),
            ],
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 200),
        child: Text(value, textAlign: TextAlign.end, style: Theme.of(context).textTheme.titleMedium),
      ),
    );
  }
}
