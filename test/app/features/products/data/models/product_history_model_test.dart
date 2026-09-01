import 'package:estoque_pro/app/features/products/data/models/product_history_model.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_history_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProductHistoryModel', () {
    final history = ProductHistoryEntity(
      action: ProductHistoryAction.add,
      quantity: 10,
      oldStock: 5,
      newStock: 15,
      date: DateTime(2026, 1, 1),
      note: 'Entrada de estoque',
      userName: 'Admin',
      isNew: false,
    );

    test('fromMap creates valid ProductHistoryModel', () {
      final map = {
        'action': 'add',
        'quantity': 10,
        'oldStock': 5,
        'newStock': 15,
        'date': 1767225600000,
        'note': 'Entrada de estoque',
        'userName': 'Admin',
      };

      final model = ProductHistoryModel.fromMap(map);

      expect(model.action, equals(ProductHistoryAction.add));
      expect(model.quantity, equals(10));
      expect(model.oldStock, equals(5));
      expect(model.newStock, equals(15));
      expect(model.note, equals('Entrada de estoque'));
      expect(model.userName, equals('Admin'));
    });

    test('toMap serializes correctly', () {
      final model = ProductHistoryModel.fromEntity(history);
      final map = model.toMap();

      expect(map['action'], equals('add'));
      expect(map['quantity'], equals(10));
      expect(map['oldStock'], equals(5));
      expect(map['newStock'], equals(15));
      expect(map['note'], equals('Entrada de estoque'));
      expect(map['userName'], equals('Admin'));
    });

    test('toEntity converts accurately', () {
      final model = ProductHistoryModel.fromEntity(history);
      final entity = model.toEntity();

      expect(entity.action, equals(ProductHistoryAction.add));
      expect(entity.quantity, equals(10));
      expect(entity.oldStock, equals(5));
      expect(entity.newStock, equals(15));
    });
  });
}
