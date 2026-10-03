import '../../../../core/utils/result.dart';
import '../../domain/models/category_model.dart';
import '../../domain/models/transaction_kind.dart';

abstract class CategoryRepositoryContract {
  Future<Result<List<CategoryModel>>> getByKind(TransactionKind kind);
  Future<Result<CategoryModel>> create(CategoryModel category);
}