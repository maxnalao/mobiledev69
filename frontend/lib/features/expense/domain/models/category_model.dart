import 'transaction_kind.dart';

class CategoryModel {
  final int id;
  final String name;
  final String icon;
  final String colorHex;
  final TransactionKind kind;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.colorHex,
    required this.kind,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int,
      name: json['name'] as String,
      icon: json['icon'] as String,
      colorHex: json['color_hex'] as String,
      kind: TransactionKind.fromApi(json['kind'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'icon': icon,
        'color_hex': colorHex,
        'kind': kind.toApi(),
      };
}