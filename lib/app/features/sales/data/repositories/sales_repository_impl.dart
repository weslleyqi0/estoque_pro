import 'package:estoque_pro/app/core/services/firebase_database_service.dart';
import 'package:estoque_pro/app/features/products/data/models/product_history_model.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_history_entity.dart';
import 'package:estoque_pro/app/features/sales/data/models/sale_model.dart';
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
                final model = SaleModel.fromMap(
                  entry.key,
                  Map<dynamic, dynamic>.from(entry.value as Map),
                );
                sales.add(model.toEntity());
              }
            }
          }
          return sales..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        })
        .handleError((e) {
          debugPrint('---> Sales: Erro no listener Firebase: $e');
        });
  }

  @override
  Future<void> save(SaleEntity sale) async {
    try {
      final pushRef = _firebaseDb.ref.push();
      final saleId = pushRef.key!;

      // Auto-generate saleNumber if empty
      final saleNumber = sale.saleNumber.isNotEmpty
          ? sale.saleNumber
          : '#${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

      final finalSale = sale.copyWith(id: saleId, saleNumber: saleNumber);
      final saleModel = SaleModel.fromEntity(finalSale);

      final Map<String, dynamic> updates = {};
      updates['sales/$saleId'] = saleModel.toMap();

      if (finalSale.status != SaleStatus.inProgress) {
        for (final item in finalSale.items) {
          final productId = item.productId;
          final prodSnapshot = await _firebaseDb.ref.root.child('products').child(productId).get();
          if (!prodSnapshot.exists || prodSnapshot.child('name').value == null) {
            debugPrint('---> Sales: Produto $productId não existe no Firebase ao salvar venda. Pulando baixa.');
            continue;
          }

          final movPushRef = _firebaseDb.ref.root.child('stock_movements').child(productId).push();

          final historyModel = ProductHistoryModel.fromEntity(
            ProductHistoryEntity(
              action: ProductHistoryAction.sale,
              quantity: item.quantity,
              oldStock: 0, // snapshot for audit
              newStock: 0,
              date: DateTime.now(),
              note: 'Venda $saleNumber',
              userName: finalSale.userName,
              isNew: true,
            ),
          );

          updates['products/$productId/stock'] = ServerValue.increment(-item.quantity);
          updates['products/$productId/updatedAt'] = ServerValue.timestamp;
          updates['stock_movements/$productId/${movPushRef.key}'] = historyModel.toMap();
        }
      }

      await _firebaseDb.updateMultiple(updates);
    } catch (e) {
      debugPrint('---> Sales: Erro ao salvar venda atômicamente: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateSale(SaleEntity sale) async {
    try {
      final saleModel = SaleModel.fromEntity(sale.copyWith(updatedAt: DateTime.now()));

      final Map<String, dynamic> updates = {};
      updates['sales/${sale.id}'] = saleModel.toMap();

      await _firebaseDb.updateMultiple(updates);
    } catch (e) {
      debugPrint('---> Sales: Erro ao atualizar venda pós-venda atômicamente: $e');
      rethrow;
    }
  }
}
