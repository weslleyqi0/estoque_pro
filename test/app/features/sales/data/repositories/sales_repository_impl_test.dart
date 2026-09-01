import 'dart:async';

import 'package:estoque_pro/app/core/services/database_service.dart';
import 'package:estoque_pro/app/features/sales/data/repositories/sales_repository_impl.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/discount_type.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/payment_method.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_edit_history_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_item_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_status.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDatabaseService extends Mock implements DatabaseService<SaleEntity> {}

void main() {
  late MockDatabaseService mockDatabaseService;
  late SalesRepositoryImpl repository;

  setUp(() {
    mockDatabaseService = MockDatabaseService();
    repository = SalesRepositoryImpl(mockDatabaseService);
  });

  const testItem = SaleItemEntity(
    productId: 'prod-1',
    productName: 'Produto A',
    productImgUrl: '',
    unitPrice: 20.0,
    quantity: 2,
  );

  final testSale = SaleEntity(
    id: 'sale-1',
    saleNumber: '#1001',
    items: const [testItem],
    subtotal: 40.0,
    discountValue: 0.0,
    discountType: DiscountType.valueAmount,
    total: 40.0,
    paymentMethod: PaymentMethod.dinheiro,
    userId: 'user-1',
    userName: 'Admin',
    status: SaleStatus.completed,
    createdAt: DateTime(2026, 1, 1),
  );

  group('SalesRepositoryImpl', () {
    test('watchAll maps and sorts sales by createdAt descending', () async {
      final controller = StreamController<Map<String, dynamic>?>();
      when(() => mockDatabaseService.listenOrdered(
            orderByChild: any(named: 'orderByChild'),
            limitToLast: any(named: 'limitToLast'),
          )).thenAnswer((_) => controller.stream);

      final stream = repository.watchAll();

      controller.add({
        'sale-1': {
          'sale_number': '#1001',
          'items': [],
          'subtotal': 40.0,
          'total': 40.0,
          'payment_method': 'dinheiro',
          'status': 'completed',
          'created_at': '2026-01-01T00:00:00.000',
        },
      });

      final result = await stream.first;

      expect(result.length, equals(1));
      expect(result.first.id, equals('sale-1'));
      expect(result.first.saleNumber, equals('#1001'));

      await controller.close();
    });

    test('save writes sale and deducts stock when completed', () async {
      when(() => mockDatabaseService.pushKey(any())).thenReturn('push-id');
      when(() => mockDatabaseService.pushKey()).thenReturn('sale-new-id');
      when(() => mockDatabaseService.increment(any())).thenReturn({'.sv': {'increment': -2}});
      when(() => mockDatabaseService.serverTimestamp).thenReturn({'.sv': 'timestamp'});
      when(() => mockDatabaseService.updateMultiple(any())).thenAnswer((_) async {});

      final result = await repository.save(testSale, productStocks: {'prod-1': 10});

      expect(result.isSuccess, isTrue);
      verify(() => mockDatabaseService.updateMultiple(any())).called(1);
    });

    test('save returns failure on error', () async {
      when(() => mockDatabaseService.pushKey()).thenReturn('sale-new-id');
      when(() => mockDatabaseService.updateMultiple(any())).thenThrow(Exception('Save sale error'));

      final result = await repository.save(testSale.copyWith(status: SaleStatus.inProgress));

      expect(result.isFailure, isTrue);
    });

    test('updateSale updates and deducts stock if transitioning from inProgress to completed', () async {
      when(() => mockDatabaseService.getChildOnce(any())).thenAnswer((_) async => {'status': 'inProgress'});
      when(() => mockDatabaseService.pushKey(any())).thenReturn('push-id');
      when(() => mockDatabaseService.increment(any())).thenReturn({'.sv': {'increment': -2}});
      when(() => mockDatabaseService.serverTimestamp).thenReturn({'.sv': 'timestamp'});
      when(() => mockDatabaseService.updateMultiple(any())).thenAnswer((_) async {});

      final result = await repository.updateSale(testSale, productStocks: {'prod-1': 10});

      expect(result.isSuccess, isTrue);
      verify(() => mockDatabaseService.updateMultiple(any())).called(1);
    });

    test('updateSaleWithStockAndHistory performs stock adjustment and creates movement log', () async {
      when(() => mockDatabaseService.pushKey(any())).thenReturn('mov-id');
      when(() => mockDatabaseService.increment(any())).thenReturn({'.sv': {'increment': -1}});
      when(() => mockDatabaseService.serverTimestamp).thenReturn({'.sv': 'timestamp'});
      when(() => mockDatabaseService.updateMultiple(any())).thenAnswer((_) async {});

      final editHistory = SaleEditHistoryEntity(
        id: 'edit-1',
        sequenceNumber: 1,
        userId: 'user-1',
        userName: 'Admin',
        timestamp: DateTime(2026, 1, 1),
        reason: 'Item adicionado',
      );

      final result = await repository.updateSaleWithStockAndHistory(
        sale: testSale,
        stockDeltas: {'prod-1': 1},
        editHistoryEntry: editHistory,
        currentProductStocks: {'prod-1': 10},
      );

      expect(result.isSuccess, isTrue);
      verify(() => mockDatabaseService.updateMultiple(any())).called(1);
    });

    test('delete calls delete on DatabaseService', () async {
      when(() => mockDatabaseService.delete(any())).thenAnswer((_) async {});

      final result = await repository.delete('sale-1');

      expect(result.isSuccess, isTrue);
      verify(() => mockDatabaseService.delete('sale-1')).called(1);
    });
  });
}
