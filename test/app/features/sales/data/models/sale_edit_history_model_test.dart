import 'package:estoque_pro/app/features/sales/data/models/sale_edit_history_model.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_edit_history_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SaleEditHistoryModel', () {
    final entry = SaleEditHistoryEntity(
      id: 'edit-1',
      sequenceNumber: 1,
      userId: 'user-1',
      userName: 'Admin',
      timestamp: DateTime(2026, 1, 1),
      reason: 'Troca de item',
      addedItems: const [],
      removedItems: const [],
      comment: 'Cliente solicitou',
    );

    test('fromMap and toMap serialize accurately', () {
      final map = {
        'id': 'edit-1',
        'sequence_number': 1,
        'user_id': 'user-1',
        'user_name': 'Admin',
        'timestamp': '2026-01-01T00:00:00.000',
        'reason': 'Troca de item',
        'added_items': [],
        'removed_items': [],
        'comment': 'Cliente solicitou',
      };

      final model = SaleEditHistoryModel.fromMap(map);

      expect(model.id, equals('edit-1'));
      expect(model.sequenceNumber, equals(1));
      expect(model.reason, equals('Troca de item'));

      final outMap = model.toMap();
      expect(outMap['id'], equals('edit-1'));
      expect(outMap['sequence_number'], equals(1));
      expect(outMap['reason'], equals('Troca de item'));
      expect(outMap['comment'], equals('Cliente solicitou'));
    });

    test('toEntity and fromEntity convert accurately', () {
      final model = SaleEditHistoryModel.fromEntity(entry);
      final entity = model.toEntity();

      expect(entity.id, equals('edit-1'));
      expect(entity.sequenceNumber, equals(1));
      expect(entity.reason, equals('Troca de item'));
    });
  });
}
