import 'package:flutter/material.dart';

import '../../../../core/utils/result.dart';
import '../../domain/contracts/transaction_repository_contract.dart';
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

  Future<bool> remove(int id) async {
    final result = await repository.delete(id);
    if (result is Ok<void>) {
      await load();
      return true;
    }
    errorMessage = (result as Err<void>).message;
    notifyListeners();
    return false;
  }

  double get totalIncome => transactions
      .where((t) => t.kind.name == 'income')
      .fold(0, (sum, t) => sum + t.amount);

  double get totalExpense => transactions
      .where((t) => t.kind.name == 'expense')
      .fold(0, (sum, t) => sum + t.amount);
}
