import 'package:estoque_pro/app/features/products/domain/entities/product_history_entity.dart';

class ProductHistoryModel {
  final ProductHistoryAction action;
  final int quantity;
  final DateTime date;
  final String note;
  final String? userName;

  const ProductHistoryModel({
    required this.action,
    required this.quantity,
    required this.date,
    this.note = '',
    this.userName,
  });

  factory ProductHistoryModel.fromMap(Map<dynamic, dynamic> map) {
    return ProductHistoryModel(
      action: ProductHistoryAction.values.firstWhere(
        (e) => e.name == map['action'],
        orElse: () => ProductHistoryAction.add,
      ),
      quantity: map['quantity'] as int? ?? 0,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int? ?? 0),
      note: map['note'] as String? ?? '',
      userName: map['userName'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'action': action.name,
      'quantity': quantity,
      'date': date.millisecondsSinceEpoch,
      'note': note,
      if (userName != null) 'userName': userName,
    };
  }

  ProductHistoryEntity toEntity() {
    return ProductHistoryEntity(
      action: action,
      quantity: quantity,
      date: date,
      note: note,
      userName: userName,
    );
  }

  factory ProductHistoryModel.fromEntity(ProductHistoryEntity entity) {
    return ProductHistoryModel(
      action: entity.action,
      quantity: entity.quantity,
      date: entity.date,
      note: entity.note,
      userName: entity.userName,
    );
  }
}
