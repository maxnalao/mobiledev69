import 'package:flutter/material.dart';

import '../../../../core/utils/result.dart';
import '../../domain/contracts/transaction_repository_contract.dart';
import '../../domain/models/transaction_kind.dart';
import '../../domain/models/transaction_model.dart';

/// ViewModel for the transaction list/CRUD screens.
/// Views only read [transactions]/[isLoading]/[errorMessage] and call the
/// methods here โ€” they never touch the repository directly.
class TransactionViewModel extends ChangeNotifier {
  final TransactionRepositoryContract repository;

  TransactionViewModel({required this.repository});

  List<TransactionModel> transactions = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final result = await repository.getAll();
    switch (result) {
      case Ok<List<TransactionModel>>():
        transactions = result.value;
      case Err<List<TransactionModel>>():
        errorMessage = result.message;
    }

    isLoading = false;
    notifyListeners();
  }

  Future<bool> add(TransactionModel transaction) async {
    final result = await repository.create(transaction);
    if (result is Ok<TransactionModel>) {
      await load();
      return true;
    }
    errorMessage = (result as Err<TransactionModel>).message;
    notifyListeners();
    return false;
  }

  Future<bool> edit(int id, TransactionModel transaction) async {
    final result = await repository.update(id, transaction);
    if (result is Ok<TransactionModel>) {
      await load();
      return true;
    }
    errorMessage = (result as Err<TransactionModel>).message;
    notifyListeners();
    return false;
  }

  /// Removes the item from the list right away (so a swiped-away tile never
  /// lingers), and puts it back if the API call fails.
  Future<bool> remove(int id) async {
    final index = transactions.indexWhere((t) => t.id == id);
    if (index == -1) return false;
    final removed = transactions.removeAt(index);
    notifyListeners();

    final result = await repository.delete(id);
    if (result is Ok<void>) {
      await load();
      return true;
    }
    transactions.insert(index, removed);
    errorMessage = (result as Err<void>).message;
    notifyListeners();
    return false;
  }

  TransactionModel? findById(int id) {
    for (final transaction in transactions) {
      if (transaction.id == id) return transaction;
    }
    return null;
  }

  /// Called by a View after it has shown [errorMessage], so it is shown once.
  void clearError() => errorMessage = null;

  double get totalIncome => transactions
      .where((t) => t.kind.name == 'income')
      .fold(0, (sum, t) => sum + t.amount);

  double get totalExpense => transactions
      .where((t) => t.kind.name == 'expense')
      .fold(0, (sum, t) => sum + t.amount);

  /// Income/expense per month for the last [months] months (oldest first),
  /// including months with no transactions so the chart has no gaps.
  List<({DateTime month, double income, double expense})> monthlyTotals({int months = 6, DateTime? now}) {
    final today = now ?? DateTime.now();
    return List.generate(months, (i) {
      final month = DateTime(today.year, today.month - (months - 1 - i));
      double income = 0, expense = 0;
      for (final t in transactions) {
        if (t.occurredOn.year != month.year || t.occurredOn.month != month.month) continue;
        if (t.kind == TransactionKind.income) {
          income += t.amount;
        } else {
          expense += t.amount;
        }
      }
      return (month: month, income: income, expense: expense);
    });
  }

  /// Total expense per category, largest first.
  List<({String category, double amount})> get expenseByCategory {
    final totals = <String, double>{};
    for (final t in transactions.where((t) => t.kind == TransactionKind.expense)) {
      final name = t.categoryName ?? 'ไม่ระบุหมวดหมู่';
      totals[name] = (totals[name] ?? 0) + t.amount;
    }
    final entries = totals.entries.map((e) => (category: e.key, amount: e.value)).toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));
    return entries;
  }
}
