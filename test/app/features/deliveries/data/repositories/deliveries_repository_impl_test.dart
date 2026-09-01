import 'dart:async';

import 'package:estoque_pro/app/core/services/database_service.dart';
import 'package:estoque_pro/app/features/deliveries/data/repositories/deliveries_repository_impl.dart';
import 'package:estoque_pro/app/features/deliveries/domain/entities/delivery_entity.dart';
import 'package:estoque_pro/app/features/deliveries/domain/entities/delivery_status.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/payment_method.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDatabaseService extends Mock implements DatabaseService<DeliveryEntity> {}

void main() {
  late MockDatabaseService mockDatabaseService;
  late DeliveriesRepositoryImpl repository;

  setUp(() {
    mockDatabaseService = MockDatabaseService();
    repository = DeliveriesRepositoryImpl(mockDatabaseService);
  });

  final testDelivery = DeliveryEntity(
    id: 'del-1',
    saleId: 'sale-1',
    saleNumber: '#1001',
    customerId: 'cust-1',
    customerName: 'João Silva',
    customerAddress: 'Rua Principal, 100',
    items: const [],
    subtotal: 150.0,
    totalAmount: 150.0,
    paymentMethod: PaymentMethod.pix,
    status: DeliveryStatus.pending,
    scheduledAt: DateTime(2026, 1, 1, 14, 0),
    createdAt: DateTime(2026, 1, 1, 10, 0),
    userId: 'user-1',
    userName: 'Admin',
  );

  group('DeliveriesRepositoryImpl', () {
    test('watchAll maps and sorts stream of deliveries by scheduledAt', () async {
      final controller = StreamController<Map<String, dynamic>?>();
      when(() => mockDatabaseService.listenOrdered(
            orderByChild: any(named: 'orderByChild'),
            limitToLast: any(named: 'limitToLast'),
          )).thenAnswer((_) => controller.stream);

      final stream = repository.watchAll();

      controller.add({
        'del-1': {
          'sale_id': 'sale-1',
          'sale_number': '#1001',
          'customer_id': 'cust-1',
          'customer_name': 'João',
          'customer_address': 'Rua 1',
          'items': [],
          'subtotal': 100.0,
          'total_amount': 100.0,
          'payment_method': 'pix',
          'status': 'pending',
          'scheduled_at': '2026-01-01T14:00:00.000',
          'created_at': '2026-01-01T10:00:00.000',
          'user_id': 'u1',
          'user_name': 'Admin',
        },
      });

      final result = await stream.first;

      expect(result.length, equals(1));
      expect(result.first.id, equals('del-1'));
      expect(result.first.customerName, equals('João'));

      await controller.close();
    });

    test('save generates pushKey when id is empty and calls updateMultiple', () async {
      when(() => mockDatabaseService.pushKey()).thenReturn('generated-key');
      when(() => mockDatabaseService.updateMultiple(any())).thenAnswer((_) async {});

      final result = await repository.save(testDelivery.copyWith(id: ''));

      expect(result.isSuccess, isTrue);
      verify(() => mockDatabaseService.pushKey()).called(1);
      verify(() => mockDatabaseService.updateMultiple(any())).called(1);
    });

    test('save returns failure on error', () async {
      when(() => mockDatabaseService.pushKey()).thenReturn('generated-key');
      when(() => mockDatabaseService.updateMultiple(any())).thenThrow(Exception('Save error'));

      final result = await repository.save(testDelivery.copyWith(id: ''));

      expect(result.isFailure, isTrue);
    });

    test('updateDelivery calls updateMultiple on DatabaseService', () async {
      when(() => mockDatabaseService.updateMultiple(any())).thenAnswer((_) async {});

      final result = await repository.updateDelivery(testDelivery);

      expect(result.isSuccess, isTrue);
      verify(() => mockDatabaseService.updateMultiple(any())).called(1);
    });

    test('updateStatus updates delivery status and deliveredAt', () async {
      when(() => mockDatabaseService.update(any(), any())).thenAnswer((_) async {});

      final result = await repository.updateStatus(
        'del-1',
        DeliveryStatus.completed,
        deliveredAt: DateTime(2026, 1, 1, 15, 0),
      );

      expect(result.isSuccess, isTrue);
      verify(() => mockDatabaseService.update('del-1', any())).called(1);
    });

    test('delete calls delete on DatabaseService', () async {
      when(() => mockDatabaseService.delete(any())).thenAnswer((_) async {});

      final result = await repository.delete('del-1');

      expect(result.isSuccess, isTrue);
      verify(() => mockDatabaseService.delete('del-1')).called(1);
    });
  });
}
