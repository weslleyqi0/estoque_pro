import 'package:estoque_pro/app/core/services/firebase_database_service.dart';
import 'package:estoque_pro/app/core/utils/sale_code_generator.dart';
import 'package:estoque_pro/app/features/products/data/models/product_history_model.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_history_entity.dart';
import 'package:estoque_pro/app/features/sales/data/models/sale_model.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_edit_history_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_status.dart';
import 'package:estoque_pro/app/features/sales/domain/repositories/sales_repository.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

class SalesRepositoryImpl implements SalesRepository {
  final FirebaseDatabaseService<SaleEntity> _firebaseDb;

  SalesRepositoryImpl(this._firebaseDb);

  @override
  Stream<List<SaleEntity>> watchAll({int limit = 50}) {
    return _firebaseDb.ref
        .orderByChild('created_at')
        .limitToLast(limit)
        .onValue
        .map((event) {
          final List<SaleEntity> sales = [];
          final value = event.snapshot.value;
          if (value is Map) {
            for (final entry in value.entries) {
              if (entry.value is Map) {
                try {
                  final model = SaleModel.fromMap(
                    entry.key.toString(),
                    Map<dynamic, dynamic>.from(entry.value as Map),
                  );
                  sales.add(model.toEntity());
                } catch (e, stack) {
                  debugPrint('---> Sales: Erro ao parsear venda ${entry.key}: $e\n$stack');
                }
              }
            }
          }
          return sales..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        })
        .handleError((e) {
          debugPrint('---> Sales: Erro no listener Firebase: $e');
        });
  }

  Future<void> _addStockDeductionUpdates(
    SaleEntity sale,
    Map<String, dynamic> updates,
    Map<String, int> productStocks,
  ) async {
    for (final item in sale.items) {
      final productId = item.productId;
      final currentStock = productStocks[productId] ?? 0;
      final newStock = currentStock - item.quantity;

      final movPushRef = _firebaseDb.ref.root.child('stock_movements').child(productId).push();

      final historyModel = ProductHistoryModel.fromEntity(
        ProductHistoryEntity(
          action: ProductHistoryAction.sale,
          quantity: item.quantity,
          oldStock: currentStock,
          newStock: newStock,
          date: DateTime.now(),
          note: 'Venda ${sale.saleNumber}',
          userName: sale.userName,
          isNew: true,
        ),
      );

      updates['products/$productId/stock'] = ServerValue.increment(-item.quantity);
      updates['products/$productId/updatedAt'] = ServerValue.timestamp;
      updates['stock_movements/$productId/${movPushRef.key}'] = historyModel.toMap();
    }
  }

  @override
  Future<void> save(SaleEntity sale, {Map<String, int>? productStocks}) async {
    try {
      final pushRef = _firebaseDb.ref.push();
      final saleId = pushRef.key!;

      // Auto-generate saleNumber if empty
      final saleNumber = sale.saleNumber.isNotEmpty
          ? sale.saleNumber
          : SaleCodeGenerator.generate();

      final finalSale = sale.copyWith(id: saleId, saleNumber: saleNumber);
      final saleModel = SaleModel.fromEntity(finalSale);

      final Map<String, dynamic> updates = {};
      updates['sales/$saleId'] = saleModel.toMap();

      if (finalSale.status != SaleStatus.inProgress) {
        await _addStockDeductionUpdates(finalSale, updates, productStocks ?? {});
      }

      await _firebaseDb.updateMultiple(updates);
    } catch (e) {
      debugPrint('---> Sales: Erro ao salvar venda atômicamente: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateSale(SaleEntity sale, {Map<String, int>? productStocks}) async {
    try {
      final oldSaleSnapshot = await _firebaseDb.ref.child(sale.id).get();
      String? oldStatus;
      final oldVal = oldSaleSnapshot.value;
      if (oldVal is Map) {
        oldStatus = oldVal['status'] as String?;
      }

      final saleModel = SaleModel.fromEntity(sale.copyWith(updatedAt: DateTime.now()));

      final Map<String, dynamic> updates = {};
      updates['sales/${sale.id}'] = saleModel.toMap();

      if (oldStatus == SaleStatus.inProgress.value && sale.status == SaleStatus.completed) {
        await _addStockDeductionUpdates(sale, updates, productStocks ?? {});
      }

      await _firebaseDb.updateMultiple(updates);
    } catch (e) {
      debugPrint('---> Sales: Erro ao atualizar venda pós-venda atômicamente: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateSaleWithStockAndHistory({
    required SaleEntity sale,
    required Map<String, int> stockDeltas,
    required SaleEditHistoryEntity editHistoryEntry,
    Map<String, int>? currentProductStocks,
  }) async {
    try {
      final saleModel = SaleModel.fromEntity(sale.copyWith(updatedAt: DateTime.now()));

      final Map<String, dynamic> updates = {};
      updates['sales/${sale.id}'] = saleModel.toMap();

      final Map<String, int> stocksMap = {};
      if (currentProductStocks != null) {
        stocksMap.addAll(currentProductStocks);
      } else {
        final productsSnap = await _firebaseDb.ref.root.child('products').get();
        if (productsSnap.exists && productsSnap.value is Map) {
          final pMap = productsSnap.value as Map;
          for (final entry in pMap.entries) {
            if (entry.value is Map) {
              final stock = (entry.value['stock'] as num?)?.toInt() ?? 0;
              stocksMap[entry.key.toString()] = stock;
            }
          }
        }
      }

      for (final entry in stockDeltas.entries) {
        final productId = entry.key;
        final delta = entry.value;

        if (delta != 0 && productId.trim().isNotEmpty) {
          final movPushRef = _firebaseDb.ref.root.child('stock_movements').child(productId).push();
          final action = delta > 0 ? ProductHistoryAction.remove : ProductHistoryAction.add;
          final note = sale.status == SaleStatus.cancelled
              ? 'Estorno por cancelamento da Venda ${sale.saleNumber}'
              : 'Edição na Venda ${sale.saleNumber} (${editHistoryEntry.reason})';

          final oldStock = stocksMap[productId] ?? 0;
          final newStock = oldStock - delta;

          final historyModel = ProductHistoryModel.fromEntity(
            ProductHistoryEntity(
              action: action,
              quantity: delta.abs(),
              oldStock: oldStock,
              newStock: newStock,
              date: DateTime.now(),
              note: note,
              userName: editHistoryEntry.userName,
              isNew: false,
            ),
          );

          updates['products/$productId/stock'] = ServerValue.increment(-delta);
          updates['products/$productId/updatedAt'] = ServerValue.timestamp;
          updates['stock_movements/$productId/${movPushRef.key}'] = historyModel.toMap();
        }
      }

      await _firebaseDb.updateMultiple(updates);
    } catch (e) {
      debugPrint('---> Sales: Erro ao atualizar venda com histórico atômicamente: $e');
      rethrow;
    }
  }

  @override
  Future<void> delete(String saleId) async {
    try {
      await _firebaseDb.delete(saleId);
    } catch (e) {
      debugPrint('---> Sales: Erro ao deletar venda: $e');
      rethrow;
    }
  }
}
