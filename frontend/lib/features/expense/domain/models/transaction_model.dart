import 'transaction_kind.dart';

class TransactionModel {
  final int? id;
  final TransactionKind kind;
  final double amount;
  final String note;
  final DateTime occurredOn;
  final int? categoryId;
  final String? categoryName;

  const TransactionModel({
    this.id,
    required this.kind,
    required this.amount,
    required this.note,
    required this.occurredOn,
    this.categoryId,
    this.categoryName,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as int?,
      kind: TransactionKind.fromApi(json['kind'] as String),
      amount: double.parse(json['amount'].toString()),
      note: (json['note'] as String?) ?? '',
      occurredOn: DateTime.parse(json['occurred_on'] as String),
      categoryId: json['category'] as int?,
      categoryName: json['category_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'kind': kind.toApi(),
        'amount': amount,
        'note': note,
        'occurred_on': occurredOn.toIso8601String().split('T').first,
        'category': categoryId,
      };
}
