import 'dart:async';

import 'package:estoque_pro/app/core/services/database_service.dart';
import 'package:estoque_pro/app/features/customers/data/repositories/customers_repository_impl.dart';
import 'package:estoque_pro/app/features/customers/domain/entities/customer_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDatabaseService extends Mock implements DatabaseService<CustomerEntity> {}

void main() {
  late MockDatabaseService mockDatabaseService;
  late CustomersRepositoryImpl repository;

  setUp(() {
    mockDatabaseService = MockDatabaseService();
    repository = CustomersRepositoryImpl(mockDatabaseService);
  });

  const testCustomer = CustomerEntity(
    id: 'cust-1',
    name: 'João Silva',
    phone: '11999999999',
    address: 'Rua A, 123',
  );

  group('CustomersRepositoryImpl', () {
    test('watchAll maps and sorts stream of customers by name', () async {
      final controller = StreamController<Map<String, dynamic>?>();
      when(() => mockDatabaseService.listen()).thenAnswer((_) => controller.stream);

      final stream = repository.watchAll();

      controller.add({
        'cust-2': {'name': 'Maria Santos', 'phone': '11888888888'},
        'cust-1': {'name': 'Ana Silva', 'phone': '11999999999'},
      });

      final result = await stream.first;

      expect(result.length, equals(2));
      expect(result.first.name, equals('Ana Silva'));
      expect(result.last.name, equals('Maria Santos'));

      await controller.close();
    });

    test('getAll returns list of customers successfully', () async {
      when(() => mockDatabaseService.getOnce()).thenAnswer((_) async => {
            'cust-1': {'name': 'João Silva', 'phone': '11999999999'},
          });

      final result = await repository.getAll();

      expect(result.isSuccess, isTrue);
      expect(result.value?.length, equals(1));
      expect(result.value?.first.name, equals('João Silva'));
    });

    test('getAll returns failure on error', () async {
      when(() => mockDatabaseService.getOnce()).thenThrow(Exception('Database error'));

      final result = await repository.getAll();

      expect(result.isFailure, isTrue);
      expect(result.error?.message, contains('Database error'));
    });

    test('save calls add on DatabaseService', () async {
      when(() => mockDatabaseService.add(any())).thenAnswer((_) async {});

      final result = await repository.save(testCustomer);

      expect(result.isSuccess, isTrue);
      verify(() => mockDatabaseService.add(any())).called(1);
    });

    test('save returns failure on exception', () async {
      when(() => mockDatabaseService.add(any())).thenThrow(Exception('Save error'));

      final result = await repository.save(testCustomer);

      expect(result.isFailure, isTrue);
    });

    test('update calls update on DatabaseService', () async {
      when(() => mockDatabaseService.update(any(), any())).thenAnswer((_) async {});

      final result = await repository.update(testCustomer);

      expect(result.isSuccess, isTrue);
      verify(() => mockDatabaseService.update('cust-1', any())).called(1);
    });

    test('delete calls delete on DatabaseService', () async {
      when(() => mockDatabaseService.delete(any())).thenAnswer((_) async {});

      final result = await repository.delete('cust-1');

      expect(result.isSuccess, isTrue);
      verify(() => mockDatabaseService.delete('cust-1')).called(1);
    });
  });
}
