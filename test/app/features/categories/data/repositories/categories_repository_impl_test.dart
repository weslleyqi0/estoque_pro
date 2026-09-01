import 'dart:async';

import 'package:estoque_pro/app/core/services/database_service.dart';
import 'package:estoque_pro/app/features/categories/data/repositories/categories_repository_impl.dart';
import 'package:estoque_pro/app/features/categories/domain/entities/category_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDatabaseService extends Mock implements DatabaseService<CategoryEntity> {}

void main() {
  late MockDatabaseService mockDatabaseService;
  late CategoriesRepositoryImpl repository;

  setUp(() {
    mockDatabaseService = MockDatabaseService();
    repository = CategoriesRepositoryImpl(mockDatabaseService);
  });

  const testCategory = CategoryEntity(
    id: 'cat-1',
    name: 'Bebidas',
    icon: 'local_drink',
    color: 0xFF123456,
  );

  group('CategoriesRepositoryImpl', () {
    test('watchAll maps and sorts stream of categories by name', () async {
      final controller = StreamController<Map<String, dynamic>?>();
      when(() => mockDatabaseService.listen()).thenAnswer((_) => controller.stream);

      final stream = repository.watchAll();

      controller.add({
        'cat-2': {'name': 'Carnes', 'icon': 'restaurant'},
        'cat-1': {'name': 'Bebidas', 'icon': 'local_drink'},
      });

      final result = await stream.first;

      expect(result.length, equals(2));
      expect(result.first.name, equals('Bebidas'));
      expect(result.last.name, equals('Carnes'));

      await controller.close();
    });

    test('getAll returns list of categories successfully', () async {
      when(() => mockDatabaseService.getOnce()).thenAnswer((_) async => {
            'cat-1': {'name': 'Bebidas', 'icon': 'local_drink', 'color': 0xFF123456},
          });

      final result = await repository.getAll();

      expect(result.isSuccess, isTrue);
      expect(result.value?.length, equals(1));
      expect(result.value?.first.name, equals('Bebidas'));
    });

    test('getAll returns failure on error', () async {
      when(() => mockDatabaseService.getOnce()).thenThrow(Exception('Database error'));

      final result = await repository.getAll();

      expect(result.isFailure, isTrue);
      expect(result.error?.message, contains('Database error'));
    });

    test('save calls add on DatabaseService', () async {
      when(() => mockDatabaseService.add(any())).thenAnswer((_) async {});

      final result = await repository.save(testCategory);

      expect(result.isSuccess, isTrue);
      verify(() => mockDatabaseService.add(any())).called(1);
    });

    test('save returns failure on exception', () async {
      when(() => mockDatabaseService.add(any())).thenThrow(Exception('Save error'));

      final result = await repository.save(testCategory);

      expect(result.isFailure, isTrue);
    });

    test('update calls update on DatabaseService', () async {
      when(() => mockDatabaseService.update(any(), any())).thenAnswer((_) async {});

      final result = await repository.update(testCategory);

      expect(result.isSuccess, isTrue);
      verify(() => mockDatabaseService.update('cat-1', any())).called(1);
    });

    test('delete calls delete on DatabaseService', () async {
      when(() => mockDatabaseService.delete(any())).thenAnswer((_) async {});

      final result = await repository.delete('cat-1');

      expect(result.isSuccess, isTrue);
      verify(() => mockDatabaseService.delete('cat-1')).called(1);
    });
  });
}
