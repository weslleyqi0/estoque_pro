import 'package:estoque_pro/app/features/suppliers/domain/entities/supplier_entity.dart';

abstract class SuppliersRepository {
  Stream<List<SupplierEntity>> watchAll();
  Future<List<SupplierEntity>> getAll();
  Future<void> save(SupplierEntity supplier);
  Future<void> update(SupplierEntity supplier);
  Future<void> delete(String id);
}
