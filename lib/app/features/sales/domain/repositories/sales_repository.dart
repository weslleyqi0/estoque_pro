import 'package:estoque_pro/app/features/sales/domain/entities/sale_edit_history_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_entity.dart';

abstract class SalesRepository {
  Future<void> save(SaleEntity sale, {Map<String, int>? productStocks});
  Stream<List<SaleEntity>> watchAll({int limit});
  Future<void> updateSale(SaleEntity sale, {Map<String, int>? productStocks});
  Future<void> updateSaleWithStockAndHistory({
    required SaleEntity sale,
    required Map<String, int> stockDeltas,
    required SaleEditHistoryEntity editHistoryEntry,
    Map<String, int>? currentProductStocks,
  });
  Future<void> delete(String saleId);
}
