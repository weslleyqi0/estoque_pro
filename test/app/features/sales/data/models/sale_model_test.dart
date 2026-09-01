import 'package:estoque_pro/app/features/sales/data/models/sale_model.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/discount_type.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/payment_method.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SaleModel', () {
    final sale = SaleEntity(
      id: 'sale-1',
      saleNumber: '#1001',
      items: const [],
      subtotal: 100.0,
      discountValue: 10.0,
      discountType: DiscountType.valueAmount,
      total: 90.0,
      paymentMethod: PaymentMethod.dinheiro,
      userId: 'user-1',
      userName: 'Admin',
      status: SaleStatus.completed,
      createdAt: DateTime(2026, 1, 1),
    );

    test('fromMap and toMap serialize accurately', () {
      final map = {
        'sale_number': '#1001',
        'items': [],
        'subtotal': 100.0,
        'discount_value': 10.0,
        'discount_type': 'value',
        'total': 90.0,
        'payment_method': 'dinheiro',
        'user_id': 'user-1',
        'user_name': 'Admin',
        'status': 'completed',
        'created_at': '2026-01-01T00:00:00.000',
      };

      final model = SaleModel.fromMap('sale-1', map);

      expect(model.id, equals('sale-1'));
      expect(model.saleNumber, equals('#1001'));
      expect(model.total, equals(90.0));
      expect(model.status, equals('completed'));

      final outMap = model.toMap();
      expect(outMap['sale_number'], equals('#1001'));
      expect(outMap['total'], equals(90.0));
      expect(outMap['status'], equals('completed'));
    });

    test('toEntity and fromEntity convert accurately', () {
      final model = SaleModel.fromEntity(sale);
      final entity = model.toEntity();

      expect(entity.id, equals('sale-1'));
      expect(entity.saleNumber, equals('#1001'));
      expect(entity.total, equals(90.0));
      expect(entity.status, equals(SaleStatus.completed));
    });
  });
}
