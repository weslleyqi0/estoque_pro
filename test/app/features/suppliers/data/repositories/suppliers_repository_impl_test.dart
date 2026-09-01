import 'dart:async';

import 'package:estoque_pro/app/core/services/database_service.dart';
import 'package:estoque_pro/app/features/suppliers/data/repositories/suppliers_repository_impl.dart';
import 'package:estoque_pro/app/features/suppliers/domain/entities/supplier_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDatabaseService extends Mock implements DatabaseService<SupplierEntity> {}

void main() {
  late MockDatabaseService mockDatabaseService;
  late SuppliersRepositoryImpl repository;

  setUp(() {
    mockDatabaseService = MockDatabaseService();
    repository = SuppliersRepositoryImpl(mockDatabaseService);
  });

  const testSupplier = SupplierEntity(
    id: 'sup-1',
    name: 'Distribuidora Central',
    cnpj: '12.345.678/0001-90',
    phone: '(11) 99999-9999',
    isActive: true,
  );

  group('SuppliersRepositoryImpl', () {
    test('watchAll maps and sorts stream of suppliers by name', () async {
      final controller = StreamController<Map<String, dynamic>?>();
      when(() => mockDatabaseService.listen()).thenAnswer((_) => controller.stream);

      final stream = repository.watchAll();

      controller.add({
        'sup-2': {'name': 'Fornecedor B', 'isActive': true},
        'sup-1': {'name': 'Fornecedor A', 'isActive': true},
      });

      final result = await stream.first;

      expect(result.length, equals(2));
      expect(result.first.name, equals('Fornecedor A'));
      expect(result.last.name, equals('Fornecedor B'));

      await controller.close();
    });

    test('getAll returns list of suppliers successfully', () async {
      when(() => mockDatabaseService.getOnce()).thenAnswer((_) async => {
            'sup-1': {'name': 'Fornecedor A', 'cnpj': '123', 'isActive': true},
          });

      final result = await repository.getAll();

      expect(result.isSuccess, isTrue);
      expect(result.value?.length, equals(1));
      expect(result.value?.first.name, equals('Fornecedor A'));
    });

    test('getAll returns failure on error', () async {
      when(() => mockDatabaseService.getOnce()).thenThrow(Exception('Database error'));

      final result = await repository.getAll();

      expect(result.isFailure, isTrue);
      expect(result.error?.message, contains('Database error'));
    });

    test('save calls add on DatabaseService', () async {
      when(() => mockDatabaseService.add(any())).thenAnswer((_) async {});

      final result = await repository.save(testSupplier);

      expect(result.isSuccess, isTrue);
      verify(() => mockDatabaseService.add(any())).called(1);
    });

    test('save returns failure on exception', () async {
      when(() => mockDatabaseService.add(any())).thenThrow(Exception('Save error'));

      final result = await repository.save(testSupplier);

      expect(result.isFailure, isTrue);
    });

    test('update calls update on DatabaseService', () async {
      when(() => mockDatabaseService.update(any(), any())).thenAnswer((_) async {});

      final result = await repository.update(testSupplier);

      expect(result.isSuccess, isTrue);
      verify(() => mockDatabaseService.update('sup-1', any())).called(1);
    });

    test('delete calls delete on DatabaseService', () async {
      when(() => mockDatabaseService.delete(any())).thenAnswer((_) async {});

      final result = await repository.delete('sup-1');

      expect(result.isSuccess, isTrue);
      verify(() => mockDatabaseService.delete('sup-1')).called(1);
    });
  });
}
