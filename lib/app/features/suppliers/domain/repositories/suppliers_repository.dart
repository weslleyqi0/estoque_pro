import 'package:estoque_pro/app/core/utils/result.dart';
import 'package:estoque_pro/app/features/suppliers/domain/entities/supplier_entity.dart';

abstract class SuppliersRepository {
  Stream<List<SupplierEntity>> watchAll();
  Future<Result<List<SupplierEntity>>> getAll();
  Future<Result<void>> save(SupplierEntity supplier);
  Future<Result<void>> update(SupplierEntity supplier);
  Future<Result<void>> delete(String id);
}
