import 'package:estoque_pro/app/features/deliveries/data/models/delivery_model.dart';
import 'package:estoque_pro/app/features/deliveries/domain/entities/delivery_status.dart';
import 'package:estoque_pro/app/features/sales/data/models/sale_item_model.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/payment_method.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DeliveryModel', () {
    final now = DateTime(2026, 8, 24, 15, 30);

    final model = DeliveryModel(
      id: 'del_100',
      saleId: 'sale_100',
      saleNumber: '#100',
      customerId: 'c10',
      customerName: 'Maria Santos',
      customerPhone: '11988887777',
      customerAddress: 'Rua Principal, 500',
      items: const [
        SaleItemModel(
          productId: 'p1',
          productName: 'Tenis Esportivo',
          productImgUrl: 'https://example.com/tenis.png',
          unitPrice: 200.0,
          quantity: 1,
        ),
      ],
      subtotal: 200.0,
      totalAmount: 200.0,
      paymentMethod: 'pix',
      status: 'pending',
      scheduledAt: now,
      deliveredAt: null,
      observations: 'Entregar na portaria',
      userId: 'u1',
      userName: 'Vendedor',
      createdAt: now,
    );

    test('toMap and fromMap conversion works as expected', () {
      final map = model.toMap();
      expect(map['sale_id'], 'sale_100');
      expect(map['sale_number'], '#100');
      expect(map['customer_name'], 'Maria Santos');
      expect(map['customer_address'], 'Rua Principal, 500');
      expect(map['payment_method'], 'pix');
      expect(map['status'], 'pending');

      final fromMapModel = DeliveryModel.fromMap('del_100', map);
      expect(fromMapModel.id, 'del_100');
      expect(fromMapModel.customerName, 'Maria Santos');
      expect(fromMapModel.items.length, 1);
      expect(fromMapModel.items.first.productName, 'Tenis Esportivo');
    });

    test('toEntity and fromEntity conversion works as expected', () {
      final entity = model.toEntity();
      expect(entity.id, 'del_100');
      expect(entity.paymentMethod, PaymentMethod.pix);
      expect(entity.status, DeliveryStatus.pending);

      final fromEntityModel = DeliveryModel.fromEntity(entity);
      expect(fromEntityModel.id, 'del_100');
      expect(fromEntityModel.paymentMethod, 'pix');
      expect(fromEntityModel.status, 'pending');
    });
  });
}
