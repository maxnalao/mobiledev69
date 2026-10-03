enum TransactionKind {
  income,
  expense;

  static TransactionKind fromApi(String value) =>
      value == 'income' ? TransactionKind.income : TransactionKind.expense;

  String toApi() => name;
}
