import 'package:estoque_pro/app/core/utils/date_parser.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_history_entity.dart';
import 'package:firebase_database/firebase_database.dart';

class ProductHistoryModel {
  final ProductHistoryAction action;
  final int quantity;
  final int oldStock;
  final int newStock;
  final DateTime date;
  final String note;
  final String? userName;
  final bool isNew;

  const ProductHistoryModel({
    required this.action,
    required this.quantity,
    required this.oldStock,
    required this.newStock,
    required this.date,
    this.note = '',
    this.userName,
    this.isNew = false,
  });

  factory ProductHistoryModel.fromMap(Map<dynamic, dynamic> map) {
    return ProductHistoryModel(
      action: ProductHistoryAction.values.firstWhere(
        (e) => e.name == map['action'],
        orElse: () => ProductHistoryAction.add,
      ),
      quantity: map['quantity'] as int? ?? 0,
      oldStock: map['oldStock'] as int? ?? 0,
      newStock: map['newStock'] as int? ?? 0,
      date: DateParser.parse(map['date']) ?? DateTime.fromMillisecondsSinceEpoch(0),
      note: map['note'] as String? ?? '',
      userName: map['userName'] as String?,
      isNew: false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'action': action.name,
      'quantity': quantity,
      'oldStock': oldStock,
      'newStock': newStock,
      'date': isNew ? ServerValue.timestamp : date.millisecondsSinceEpoch,
      'note': note,
      if (userName != null) 'userName': userName,
    };
  }

  ProductHistoryEntity toEntity() {
    return ProductHistoryEntity(
      action: action,
      quantity: quantity,
      oldStock: oldStock,
      newStock: newStock,
      date: date,
      note: note,
      userName: userName,
      isNew: isNew,
    );
  }

  factory ProductHistoryModel.fromEntity(ProductHistoryEntity entity) {
    return ProductHistoryModel(
      action: entity.action,
      quantity: entity.quantity,
      oldStock: entity.oldStock,
      newStock: entity.newStock,
      date: entity.date,
      note: entity.note,
      userName: entity.userName,
      isNew: entity.isNew,
    );
  }
}
