import 'package:expense_tracker/core/utils/result.dart';
import 'package:expense_tracker/features/expense/domain/contracts/transaction_repository_contract.dart';
import 'package:expense_tracker/features/expense/domain/models/transaction_kind.dart';
import 'package:expense_tracker/features/expense/domain/models/transaction_model.dart';
import 'package:expense_tracker/features/expense/presentation/viewmodels/transaction_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeTransactionRepository implements TransactionRepositoryContract {
  List<TransactionModel> items;
  bool failDelete = false;

  FakeTransactionRepository(this.items);

  @override
  Future<Result<List<TransactionModel>>> getAll() async => Ok(List.of(items));

  @override
  Future<Result<TransactionModel>> create(TransactionModel transaction) async {
    items.add(transaction);
    return Ok(transaction);
  }

  @override
  Future<Result<TransactionModel>> update(int id, TransactionModel transaction) async => Ok(transaction);

  @override
  Future<Result<void>> delete(int id) async {
    if (failDelete) return const Err('เชื่อมต่อเซิร์ฟเวอร์ไม่ได้');
    items.removeWhere((t) => t.id == id);
    return const Ok(null);
  }

  @override
  Future<Result<Map<String, double>>> getSummary() async => const Ok({});
}

TransactionModel _tx(int id, TransactionKind kind, double amount) =>
    TransactionModel(id: id, kind: kind, amount: amount, note: '', occurredOn: DateTime(2026, 10, 1));

void main() {
  test('TransactionModel parses API JSON', () {
    final model = TransactionModel.fromJson({
      'id': 1,
      'kind': 'expense',
      'amount': '120.00',
      'note': 'ข้าวกลางวัน',
      'occurred_on': '2026-10-01',
      'category': 3,
      'category_name': 'อาหาร',
    });

    expect(model.kind, TransactionKind.expense);
    expect(model.amount, 120);
    expect(model.toJson()['occurred_on'], '2026-10-01');
  });

  test('load computes income and expense totals', () async {
    final viewModel = TransactionViewModel(
      repository: FakeTransactionRepository([
        _tx(1, TransactionKind.income, 15000),
        _tx(2, TransactionKind.expense, 120),
      ]),
    );

    await viewModel.load();

    expect(viewModel.totalIncome, 15000);
    expect(viewModel.totalExpense, 120);
    expect(viewModel.findById(2)?.amount, 120);
  });

  test('monthlyTotals and expenseByCategory group transactions', () async {
    final viewModel = TransactionViewModel(
      repository: FakeTransactionRepository([
        TransactionModel(id: 1, kind: TransactionKind.income, amount: 1000, note: '', occurredOn: DateTime(2026, 10, 1)),
        TransactionModel(id: 2, kind: TransactionKind.expense, amount: 300, note: '', occurredOn: DateTime(2026, 10, 2), categoryName: 'อาหาร'),
        TransactionModel(id: 3, kind: TransactionKind.expense, amount: 500, note: '', occurredOn: DateTime(2026, 9, 5), categoryName: 'เดินทาง'),
        TransactionModel(id: 4, kind: TransactionKind.expense, amount: 100, note: '', occurredOn: DateTime(2026, 9, 6), categoryName: 'อาหาร'),
      ]),
    );
    await viewModel.load();

    final months = viewModel.monthlyTotals(months: 3, now: DateTime(2026, 10, 15));
    expect(months.map((m) => m.month.month), [8, 9, 10]);
    expect(months.last.income, 1000);
    expect(months[1].expense, 600);

    final byCategory = viewModel.expenseByCategory;
    expect(byCategory.first.category, 'เดินทาง');
    expect(byCategory.map((c) => c.amount), [500, 400]);
  });

  test('failed delete restores the item and exposes an error', () async {
    final repository = FakeTransactionRepository([_tx(1, TransactionKind.expense, 50)])..failDelete = true;
    final viewModel = TransactionViewModel(repository: repository);
    await viewModel.load();

    final success = await viewModel.remove(1);

    expect(success, isFalse);
    expect(viewModel.transactions, hasLength(1));
    expect(viewModel.errorMessage, isNotNull);
  });
}
