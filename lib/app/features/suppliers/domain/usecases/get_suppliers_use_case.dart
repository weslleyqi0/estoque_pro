import 'package:estoque_pro/app/core/utils/result.dart';
import 'package:estoque_pro/app/features/suppliers/domain/entities/supplier_entity.dart';
import 'package:estoque_pro/app/features/suppliers/domain/repositories/suppliers_repository.dart';

class GetSuppliersUseCase {
  final SuppliersRepository _repository;

  const GetSuppliersUseCase(this._repository);

  Stream<List<SupplierEntity>> watchAll() {
    return _repository.watchAll();
  }

  Future<Result<List<SupplierEntity>>> getAll() {
    return _repository.getAll();
  }
}
