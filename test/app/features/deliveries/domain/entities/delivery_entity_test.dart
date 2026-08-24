import 'package:estoque_pro/app/features/deliveries/domain/entities/delivery_entity.dart';
import 'package:estoque_pro/app/features/deliveries/domain/entities/delivery_status.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/payment_method.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_item_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DeliveryEntity', () {
    const item1 = SaleItemEntity(
      productId: 'p1',
      productName: 'Camisa',
      productImgUrl: '',
      unitPrice: 50.0,
      quantity: 2,
    );

    final delivery = DeliveryEntity(
      id: 'del_1',
      saleId: 'sale_1',
      saleNumber: '#1001',
      customerId: 'c1',
      customerName: 'João da Silva',
      customerPhone: '11999999999',
      customerAddress: 'Rua A, 123',
      items: const [item1],
      subtotal: 100.0,
      totalAmount: 100.0,
      paymentMethod: PaymentMethod.dinheiro,
      status: DeliveryStatus.pending,
      scheduledAt: DateTime.now().add(const Duration(hours: 2)),
      userId: 'u1',
      userName: 'Vendedor 1',
      createdAt: DateTime.now(),
    );

    test('totalItems returns sum of item quantities', () {
      expect(delivery.totalItems, 2);
    });

    test('isDelayed returns false when scheduled in future', () {
      expect(delivery.isDelayed, false);
      expect(delivery.effectiveStatus, DeliveryStatus.pending);
    });

    test('isDelayed returns true when scheduled in the past and pending', () {
      final delayed = delivery.copyWith(
        scheduledAt: DateTime.now().subtract(const Duration(hours: 2)),
      );
      expect(delayed.isDelayed, true);
      expect(delayed.effectiveStatus, DeliveryStatus.delayed);
    });

    test('isDelayed returns false when completed even if scheduled in past', () {
      final completed = delivery.copyWith(
        status: DeliveryStatus.completed,
        scheduledAt: DateTime.now().subtract(const Duration(hours: 2)),
      );
      expect(completed.isDelayed, false);
      expect(completed.effectiveStatus, DeliveryStatus.completed);
    });

    test('isDelayed returns false when cancelled even if scheduled in past', () {
      final cancelled = delivery.copyWith(
        status: DeliveryStatus.cancelled,
        scheduledAt: DateTime.now().subtract(const Duration(hours: 2)),
      );
      expect(cancelled.isDelayed, false);
      expect(cancelled.effectiveStatus, DeliveryStatus.cancelled);
    });

    test('copyWith updates properties correctly', () {
      final updated = delivery.copyWith(
        status: DeliveryStatus.inProgress,
        customerAddress: 'Rua Nova, 456',
      );
      expect(updated.status, DeliveryStatus.inProgress);
      expect(updated.customerAddress, 'Rua Nova, 456');
      expect(updated.id, 'del_1');
    });
  });
}
