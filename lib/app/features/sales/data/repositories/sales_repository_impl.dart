import 'package:estoque_pro/app/core/services/database_service.dart';
import 'package:estoque_pro/app/core/utils/result.dart';
import 'package:estoque_pro/app/core/utils/sale_code_generator.dart';
import 'package:estoque_pro/app/features/products/data/models/product_history_model.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_history_entity.dart';
import 'package:estoque_pro/app/features/sales/data/models/sale_model.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_edit_history_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_status.dart';
import 'package:estoque_pro/app/features/deliveries/data/models/delivery_model.dart';
import 'package:estoque_pro/app/features/deliveries/domain/entities/delivery_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/repositories/sales_repository.dart';
import 'package:flutter/foundation.dart';

class SalesRepositoryImpl implements SalesRepository {
  final DatabaseService<SaleEntity> _databaseService;

  SalesRepositoryImpl(this._databaseService);

  @override
  Stream<List<SaleEntity>> watchAll({int limit = 50}) {
    return _databaseService
        .listenOrdered(
          orderByChild: 'created_at',
          limitToLast: limit,
        )
        .map((data) {
          final List<SaleEntity> sales = [];
          if (data != null) {
            for (final entry in data.entries) {
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
          debugPrint('---> Sales: Erro no listener: $e');
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

      final movPushKey = _databaseService.pushKey('stock_movements/$productId');

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

      updates['products/$productId/stock'] = _databaseService.increment(-item.quantity);
      updates['products/$productId/updatedAt'] = _databaseService.serverTimestamp;
      final movMap = historyModel.toMap();
      movMap['date'] = _databaseService.serverTimestamp;
      updates['stock_movements/$productId/$movPushKey'] = movMap;
    }
  }

  @override
  Future<Result<SaleEntity>> save(
    SaleEntity sale, {
    Map<String, int>? productStocks,
    DeliveryEntity? delivery,
  }) async {
    try {
      final pushKey = _databaseService.pushKey();
      final saleId = sale.id.isNotEmpty ? sale.id : pushKey;

      // Auto-generate saleNumber if empty
      final saleNumber = sale.saleNumber.isNotEmpty ? sale.saleNumber : SaleCodeGenerator.generate();

      final finalSale = sale.copyWith(id: saleId, saleNumber: saleNumber);
      final saleModel = SaleModel.fromEntity(finalSale);
      final saleModelMap = saleModel.toMap();
      // Garante que as datas venham diretamente do servidor do Firebase
      saleModelMap['created_at'] = _databaseService.serverTimestamp;
      saleModelMap['updated_at'] = _databaseService.serverTimestamp;

      final Map<String, dynamic> updates = {};
      updates['sales/$saleId'] = saleModelMap;

      if (finalSale.status != SaleStatus.inProgress) {
        await _addStockDeductionUpdates(finalSale, updates, productStocks ?? {});
      }

      if (delivery != null) {
        final deliveryPushKey = _databaseService.pushKey();
        final deliveryId = delivery.id.isNotEmpty ? delivery.id : deliveryPushKey;
        final finalDelivery = delivery.copyWith(
          id: deliveryId,
          saleId: saleId,
          saleNumber: saleNumber,
        );
        final deliveryModel = DeliveryModel.fromEntity(finalDelivery);
        final deliveryModelMap = deliveryModel.toMap();
        deliveryModelMap['created_at'] = _databaseService.serverTimestamp;
        deliveryModelMap['updated_at'] = _databaseService.serverTimestamp;
        updates['deliveries/$deliveryId'] = deliveryModelMap;
      }

      await _databaseService.updateMultiple(updates);
      return Result.success(finalSale);
    } catch (e, stackTrace) {
      debugPrint('---> Sales: Erro ao salvar venda atômicamente: $e');
      return Result.failure(e, stackTrace);
    }
  }

  @override
  Future<Result<SaleEntity>> updateSale(
    SaleEntity sale, {
    Map<String, int>? productStocks,
    DeliveryEntity? delivery,
  }) async {
    try {
      final oldVal = await _databaseService.getChildOnce(sale.id);
      String? oldStatus;
      if (oldVal != null) {
        oldStatus = oldVal['status'] as String?;
      }

      final saleModel = SaleModel.fromEntity(sale.copyWith(updatedAt: DateTime.now()));
      final saleModelMap = saleModel.toMap();
      saleModelMap['updated_at'] = _databaseService.serverTimestamp;

      final Map<String, dynamic> updates = {};
      updates['sales/${sale.id}'] = saleModelMap;

      if (oldStatus == SaleStatus.inProgress.value && sale.status == SaleStatus.completed) {
        await _addStockDeductionUpdates(sale, updates, productStocks ?? {});
      }

      if (delivery != null) {
        final deliveryPushKey = _databaseService.pushKey();
        final deliveryId = delivery.id.isNotEmpty ? delivery.id : deliveryPushKey;
        final finalDelivery = delivery.copyWith(
          id: deliveryId,
          saleId: sale.id,
          saleNumber: sale.saleNumber,
        );
        final deliveryModel = DeliveryModel.fromEntity(finalDelivery);
        final deliveryModelMap = deliveryModel.toMap();
        deliveryModelMap['created_at'] = _databaseService.serverTimestamp;
        deliveryModelMap['updated_at'] = _databaseService.serverTimestamp;
        updates['deliveries/$deliveryId'] = deliveryModelMap;
      }

      await _databaseService.updateMultiple(updates);
      return Result.success(sale);
    } catch (e, stackTrace) {
      debugPrint('---> Sales: Erro ao atualizar venda pós-venda atômicamente: $e');
      return Result.failure(e, stackTrace);
    }
  }

  @override
  Future<Result<void>> updateSaleWithStockAndHistory({
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
        final pMap = await _databaseService.queryOnce(subPath: 'products');
        if (pMap != null) {
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
          final movPushKey = _databaseService.pushKey('stock_movements/$productId');
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

          updates['products/$productId/stock'] = _databaseService.increment(-delta);
          updates['products/$productId/updatedAt'] = _databaseService.serverTimestamp;
          updates['stock_movements/$productId/$movPushKey'] = historyModel.toMap();
        }
      }

      await _databaseService.updateMultiple(updates);
      return const Result.success(null);
    } catch (e, stackTrace) {
      debugPrint('---> Sales: Erro ao atualizar venda com histórico atômicamente: $e');
      return Result.failure(e, stackTrace);
    }
  }

  @override
  Future<Result<void>> updateCustomer(
    String saleId, {
    required String customerId,
    required String customerName,
  }) async {
    try {
      final updates = <String, dynamic>{
        'sales/$saleId/customer_id': customerId,
        'sales/$saleId/customer_name': customerName,
        'sales/$saleId/updated_at': _databaseService.serverTimestamp,
      };
      await _databaseService.updateMultiple(updates);
      return const Result.success(null);
    } catch (e, stackTrace) {
      debugPrint('---> Sales: Erro ao atualizar cliente da venda: $e');
      return Result.failure(e, stackTrace);
    }
  }

  @override
  Future<Result<void>> delete(String saleId) async {
    try {
      await _databaseService.delete(saleId);
      return const Result.success(null);
    } catch (e, stackTrace) {
      debugPrint('---> Sales: Erro ao deletar venda: $e');
      return Result.failure(e, stackTrace);
    }
  }
}
