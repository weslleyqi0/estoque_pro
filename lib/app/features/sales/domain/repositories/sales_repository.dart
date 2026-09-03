import 'package:estoque_pro/app/core/utils/result.dart';
import 'package:estoque_pro/app/features/deliveries/domain/entities/delivery_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_edit_history_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_entity.dart';

abstract class SalesRepository {
  Future<Result<SaleEntity>> save(
    SaleEntity sale, {
    Map<String, int>? productStocks,
    DeliveryEntity? delivery,
  });
  Stream<List<SaleEntity>> watchAll({int limit});
  Future<Result<SaleEntity>> updateSale(
    SaleEntity sale, {
    Map<String, int>? productStocks,
    DeliveryEntity? delivery,
  });
  Future<Result<void>> updateSaleWithStockAndHistory({
    required SaleEntity sale,
    required Map<String, int> stockDeltas,
    required SaleEditHistoryEntity editHistoryEntry,
    Map<String, int>? currentProductStocks,
  });
  Future<Result<void>> updateCustomer(
    String saleId, {
    required String customerId,
    required String customerName,
  });
  Future<Result<void>> delete(String saleId);
}
