import 'dart:async';

import 'package:estoque_pro/app/core/services/database_service.dart';
import 'package:estoque_pro/app/features/customers/data/repositories/customer_payments_repository_impl.dart';
import 'package:estoque_pro/app/features/customers/domain/entities/customer_payment_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/payment_method.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDatabaseService extends Mock implements DatabaseService<CustomerPaymentEntity> {}

void main() {
  late MockDatabaseService mockDatabaseService;
  late CustomerPaymentsRepositoryImpl repository;

  setUp(() {
    mockDatabaseService = MockDatabaseService();
    repository = CustomerPaymentsRepositoryImpl(mockDatabaseService);
  });

  final testPayment = CustomerPaymentEntity(
    id: 'pay-1',
    customerId: 'cust-1',
    customerName: 'João Silva',
    amount: 150.0,
    paymentMethod: PaymentMethod.pix,
    userId: 'user-1',
    userName: 'Admin',
    createdAt: DateTime(2026, 1, 1),
  );

  group('CustomerPaymentsRepositoryImpl', () {
    test('watchAll maps and sorts payments by createdAt descending', () async {
      final controller = StreamController<Map<String, dynamic>?>();
      when(() => mockDatabaseService.listen()).thenAnswer((_) => controller.stream);

      final stream = repository.watchAll();

      controller.add({
        'pay-1': {
          'customer_id': 'cust-1',
          'amount': 50.0,
          'payment_method': 'pix',
          'created_at': '2026-01-01T00:00:00.000',
        },
        'pay-2': {
          'customer_id': 'cust-1',
          'amount': 100.0,
          'payment_method': 'money',
          'created_at': '2026-01-02T00:00:00.000',
        },
      });

      final result = await stream.first;

      expect(result.length, equals(2));
      expect(result.first.id, equals('pay-2'));
      expect(result.last.id, equals('pay-1'));

      await controller.close();
    });

    test('getAll returns list of payments', () async {
      when(() => mockDatabaseService.getOnce()).thenAnswer((_) async => {
            'pay-1': {
              'customer_id': 'cust-1',
              'amount': 50.0,
              'payment_method': 'pix',
              'created_at': '2026-01-01T00:00:00.000',
            },
          });

      final result = await repository.getAll();

      expect(result.isSuccess, isTrue);
      expect(result.value?.length, equals(1));
      expect(result.value?.first.id, equals('pay-1'));
    });

    test('getAll returns failure on error', () async {
      when(() => mockDatabaseService.getOnce()).thenThrow(Exception('Database error'));

      final result = await repository.getAll();

      expect(result.isFailure, isTrue);
    });

    test('save with empty id calls add on DatabaseService', () async {
      when(() => mockDatabaseService.add(any())).thenAnswer((_) async {});

      final result = await repository.save(testPayment.copyWith(id: ''));

      expect(result.isSuccess, isTrue);
      verify(() => mockDatabaseService.add(any())).called(1);
    });

    test('save with existing id calls update on DatabaseService', () async {
      when(() => mockDatabaseService.update(any(), any())).thenAnswer((_) async {});

      final result = await repository.save(testPayment);

      expect(result.isSuccess, isTrue);
      verify(() => mockDatabaseService.update('pay-1', any())).called(1);
    });

    test('delete calls delete on DatabaseService', () async {
      when(() => mockDatabaseService.delete(any())).thenAnswer((_) async {});

      final result = await repository.delete('pay-1');

      expect(result.isSuccess, isTrue);
      verify(() => mockDatabaseService.delete('pay-1')).called(1);
    });
  });
}
