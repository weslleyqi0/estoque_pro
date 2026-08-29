import 'package:estoque_pro/app/features/customers/data/models/customer_payment_model.dart';
import 'package:estoque_pro/app/features/customers/domain/entities/customer_payment_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/payment_method.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CustomerPaymentModel & CustomerPaymentEntity Tests', () {
    final fixedDate = DateTime(2026, 8, 26, 14, 30);
    final cancelledDate = DateTime(2026, 8, 26, 16, 0);

    final testEntity = CustomerPaymentEntity(
      id: 'pay_1',
      customerId: 'cust_1',
      customerName: 'João Silva',
      amount: 150.0,
      paymentMethod: PaymentMethod.pix,
      notes: 'Pagamento parcial',
      userId: 'user_1',
      userName: 'Vendedor Teste',
      createdAt: fixedDate,
      isCancelled: true,
      cancelledAt: cancelledDate,
      cancellationReason: 'Lançamento em duplicidade',
    );

    test('toEntity converts Model to Entity accurately', () {
      final model = CustomerPaymentModel(
        id: 'pay_1',
        customerId: 'cust_1',
        customerName: 'João Silva',
        amount: 150.0,
        paymentMethod: PaymentMethod.pix,
        notes: 'Pagamento parcial',
        userId: 'user_1',
        userName: 'Vendedor Teste',
        createdAt: fixedDate,
        isCancelled: true,
        cancelledAt: cancelledDate,
        cancellationReason: 'Lançamento em duplicidade',
      );

      final entity = model.toEntity();
      expect(entity, equals(testEntity));
    });

    test('fromEntity converts Entity to Model accurately', () {
      final model = CustomerPaymentModel.fromEntity(testEntity);
      expect(model.id, 'pay_1');
      expect(model.customerId, 'cust_1');
      expect(model.customerName, 'João Silva');
      expect(model.amount, 150.0);
      expect(model.paymentMethod, PaymentMethod.pix);
      expect(model.notes, 'Pagamento parcial');
      expect(model.userId, 'user_1');
      expect(model.userName, 'Vendedor Teste');
      expect(model.createdAt, fixedDate);
      expect(model.isCancelled, isTrue);
      expect(model.cancelledAt, cancelledDate);
      expect(model.cancellationReason, 'Lançamento em duplicidade');
    });

    test('fromMap parses map correctly', () {
      final map = {
        'customer_id': 'cust_2',
        'customer_name': 'Maria Santos',
        'amount': 80.5,
        'payment_method': 'dinheiro',
        'notes': 'Acerto total',
        'user_id': 'user_2',
        'user_name': 'Admin',
        'created_at': fixedDate.toIso8601String(),
        'is_cancelled': true,
        'cancelled_at': cancelledDate.toIso8601String(),
        'cancellation_reason': 'Estorno a pedido do cliente',
      };

      final model = CustomerPaymentModel.fromMap('pay_2', map);
      expect(model.id, 'pay_2');
      expect(model.customerId, 'cust_2');
      expect(model.customerName, 'Maria Santos');
      expect(model.amount, 80.5);
      expect(model.paymentMethod, PaymentMethod.dinheiro);
      expect(model.notes, 'Acerto total');
      expect(model.userId, 'user_2');
      expect(model.userName, 'Admin');
      expect(model.createdAt, fixedDate);
      expect(model.isCancelled, isTrue);
      expect(model.cancelledAt, cancelledDate);
      expect(model.cancellationReason, 'Estorno a pedido do cliente');
    });

    test('toMap serializes entity correctly', () {
      final map = CustomerPaymentModel.fromEntity(testEntity).toMap();
      expect(map['customer_id'], 'cust_1');
      expect(map['customer_name'], 'João Silva');
      expect(map['amount'], 150.0);
      expect(map['payment_method'], 'pix');
      expect(map['notes'], 'Pagamento parcial');
      expect(map['user_id'], 'user_1');
      expect(map['user_name'], 'Vendedor Teste');
      expect(map['created_at'], fixedDate.toIso8601String());
      expect(map['is_cancelled'], isTrue);
      expect(map['cancelled_at'], cancelledDate.toIso8601String());
      expect(map['cancellation_reason'], 'Lançamento em duplicidade');
    });
  });
}
