import 'package:flutter/material.dart';

import '../../../../core/utils/result.dart';
import '../../domain/contracts/category_repository_contract.dart';
import '../../domain/models/category_model.dart';
import '../../domain/models/transaction_kind.dart';

class CategoryViewModel extends ChangeNotifier {
  final CategoryRepositoryContract repository;

  CategoryViewModel({required this.repository});

  List<CategoryModel> categories = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadForKind(TransactionKind kind) async {
    isLoading = true;
    notifyListeners();

    final result = await repository.getByKind(kind);
    switch (result) {
      case Ok<List<CategoryModel>>():
        categories = result.value;
      case Err<List<CategoryModel>>():
        errorMessage = result.message;
    }

    isLoading = false;
    notifyListeners();
  }

  Future<CategoryModel?> create({required String name, required TransactionKind kind}) async {
    final result = await repository.create(CategoryModel(id: 0, name: name, icon: 'category', colorHex: '#6750A4', kind: kind));
    if (result is Ok<CategoryModel>) {
      await loadForKind(kind);
      return result.value;
    }
    errorMessage = (result as Err<CategoryModel>).message;
    notifyListeners();
    return null;
  }
}