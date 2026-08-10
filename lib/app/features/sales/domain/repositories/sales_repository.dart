import 'package:estoque_pro/app/features/sales/domain/entities/sale_entity.dart';

abstract class SalesRepository {
  Future<void> save(SaleEntity sale);
  Stream<List<SaleEntity>> watchAll({int limit});
  Future<void> updateSale(SaleEntity sale);
}
