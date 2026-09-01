import 'dart:async';

import 'package:estoque_pro/app/core/services/database_service.dart';
import 'package:estoque_pro/app/features/products/data/repositories/products_repository_impl.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_entity.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_history_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDatabaseService extends Mock implements DatabaseService<ProductEntity> {}

void main() {
  late MockDatabaseService mockDatabaseService;
  late ProductsRepositoryImpl repository;

  setUp(() {
    mockDatabaseService = MockDatabaseService();
    repository = ProductsRepositoryImpl(mockDatabaseService);
  });

  const testProduct = ProductEntity(
    id: 'prod-1',
    name: 'Arroz 5kg',
    imgUrl: '',
    description: 'Arroz branco',
    categories: [],
    price: 25.0,
    costPrice: 18.0,
    stock: 20,
    minStock: 5,
  );

  group('ProductsRepositoryImpl', () {
    test('watchAll maps and sorts products by name', () async {
      final controller = StreamController<Map<String, dynamic>?>();
      when(() => mockDatabaseService.listen()).thenAnswer((_) => controller.stream);

      final stream = repository.watchAll();

      controller.add({
        'prod-2': {'name': 'Feijão 1kg', 'price': 8.0, 'stock': 10},
        'prod-1': {'name': 'Arroz 5kg', 'price': 25.0, 'stock': 20},
      });

      final result = await stream.first;

      expect(result.length, equals(2));
      expect(result.first.name, equals('Arroz 5kg'));
      expect(result.last.name, equals('Feijão 1kg'));

      await controller.close();
    });

    test('getAll returns products list', () async {
      when(() => mockDatabaseService.getOnce()).thenAnswer((_) async => {
            'prod-1': {'name': 'Arroz 5kg', 'price': 25.0, 'stock': 20},
          });

      final result = await repository.getAll();

      expect(result.isSuccess, isTrue);
      expect(result.value?.length, equals(1));
      expect(result.value?.first.name, equals('Arroz 5kg'));
    });

    test('save calls add on DatabaseService', () async {
      when(() => mockDatabaseService.add(any())).thenAnswer((_) async {});

      final result = await repository.save(testProduct);

      expect(result.isSuccess, isTrue);
      verify(() => mockDatabaseService.add(any())).called(1);
    });

    test('update calls update on DatabaseService', () async {
      when(() => mockDatabaseService.update(any(), any())).thenAnswer((_) async {});

      final result = await repository.update(testProduct);

      expect(result.isSuccess, isTrue);
      verify(() => mockDatabaseService.update('prod-1', any())).called(1);
    });

    test('archive updates isActive and isArchived flags', () async {
      when(() => mockDatabaseService.update(any(), any())).thenAnswer((_) async {});

      final result = await repository.archive('prod-1');

      expect(result.isSuccess, isTrue);
      verify(() => mockDatabaseService.update('prod-1', {'isActive': false, 'isArchived': true})).called(1);
    });

    test('unarchive updates isActive and isArchived flags', () async {
      when(() => mockDatabaseService.update(any(), any())).thenAnswer((_) async {});

      final result = await repository.unarchive('prod-1');

      expect(result.isSuccess, isTrue);
      verify(() => mockDatabaseService.update('prod-1', {'isActive': false, 'isArchived': false})).called(1);
    });

    test('deletePermanently calls updateMultiple with null paths', () async {
      when(() => mockDatabaseService.updateMultiple(any())).thenAnswer((_) async {});

      final result = await repository.deletePermanently('prod-1');

      expect(result.isSuccess, isTrue);
      verify(() => mockDatabaseService.updateMultiple({
            'products/prod-1': null,
            'stock_movements/prod-1': null,
          })).called(1);
    });

    test('adjustStock validates productId and quantityDiff', () async {
      final history = ProductHistoryEntity(
        action: ProductHistoryAction.add,
        quantity: 5,
        oldStock: 10,
        newStock: 15,
        date: DateTime(2026, 1, 1),
      );

      final emptyIdResult = await repository.adjustStock('', 5, history);
      expect(emptyIdResult.isFailure, isTrue);

      final zeroDiffResult = await repository.adjustStock('prod-1', 0, history);
      expect(zeroDiffResult.isFailure, isTrue);
    });

    test('adjustStock calls updateMultiple with increment and movement entry', () async {
      when(() => mockDatabaseService.pushKey(any())).thenReturn('mov-key');
      when(() => mockDatabaseService.increment(any())).thenReturn({'.sv': {'increment': 5}});
      when(() => mockDatabaseService.serverTimestamp).thenReturn({'.sv': 'timestamp'});
      when(() => mockDatabaseService.updateMultiple(any())).thenAnswer((_) async {});

      final history = ProductHistoryEntity(
        action: ProductHistoryAction.add,
        quantity: 5,
        oldStock: 10,
        newStock: 15,
        date: DateTime(2026, 1, 1),
      );

      final result = await repository.adjustStock('prod-1', 5, history);

      expect(result.isSuccess, isTrue);
      verify(() => mockDatabaseService.updateMultiple(any())).called(1);
    });

    test('watchHistory maps and sorts stock movements by date descending', () async {
      final controller = StreamController<Map<String, dynamic>?>();
      when(() => mockDatabaseService.listenOrdered(
            subPath: any(named: 'subPath'),
            orderByChild: any(named: 'orderByChild'),
            limitToLast: any(named: 'limitToLast'),
          )).thenAnswer((_) => controller.stream);

      final stream = repository.watchHistory('prod-1');

      controller.add({
        'mov-1': {
          'action': 'add',
          'quantity': 5,
          'oldStock': 10,
          'newStock': 15,
          'date': 1767225600000,
        },
      });

      final result = await stream.first;

      expect(result.length, equals(1));
      expect(result.first.quantity, equals(5));

      await controller.close();
    });

    test('checkBarcodeExists returns false for empty barcode', () async {
      final result = await repository.checkBarcodeExists('  ');
      expect(result.isSuccess, isTrue);
      expect(result.value, isFalse);
    });

    test('checkBarcodeExists returns true when barcode exists on another product', () async {
      when(() => mockDatabaseService.queryOnce(
            orderByChild: any(named: 'orderByChild'),
            equalTo: any(named: 'equalTo'),
            timeout: any(named: 'timeout'),
          )).thenAnswer((_) async => {
            'prod-2': {'name': 'Outro Produto', 'barcode': '789123456'},
          });

      final result = await repository.checkBarcodeExists('789123456', ignoreId: 'prod-1');

      expect(result.isSuccess, isTrue);
      expect(result.value, isTrue);
    });

    test('checkBarcodeExists returns false when barcode belongs to ignored product itself', () async {
      when(() => mockDatabaseService.queryOnce(
            orderByChild: any(named: 'orderByChild'),
            equalTo: any(named: 'equalTo'),
            timeout: any(named: 'timeout'),
          )).thenAnswer((_) async => {
            'prod-1': {'name': 'Arroz', 'barcode': '789123456'},
          });

      final result = await repository.checkBarcodeExists('789123456', ignoreId: 'prod-1');

      expect(result.isSuccess, isTrue);
      expect(result.value, isFalse);
    });
  });
}
