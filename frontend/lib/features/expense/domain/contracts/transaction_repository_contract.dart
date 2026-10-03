import '../../../../core/utils/result.dart';
import '../models/transaction_model.dart';

abstract class TransactionRepositoryContract {
  Future<Result<List<TransactionModel>>> getAll();
  Future<Result<TransactionModel>> create(TransactionModel transaction);
  Future<Result<TransactionModel>> update(int id, TransactionModel transaction);
  Future<Result<void>> delete(int id);
  Future<Result<Map<String, double>>> getSummary();
}
