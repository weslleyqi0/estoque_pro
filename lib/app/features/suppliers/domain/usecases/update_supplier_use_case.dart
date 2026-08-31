import 'package:estoque_pro/app/core/utils/result.dart';
import 'package:estoque_pro/app/features/suppliers/domain/entities/supplier_entity.dart';
import 'package:estoque_pro/app/features/suppliers/domain/repositories/suppliers_repository.dart';

class UpdateSupplierUseCase {
  final SuppliersRepository _repository;

  const UpdateSupplierUseCase(this._repository);

  AsyncResult<bool> call(SupplierEntity supplier) async {
    return Result.guard(() async {
      if (supplier.id.trim().isEmpty) {
        throw const BusinessRuleFailure(message: 'ID do fornecedor inválido.');
      }
      if (supplier.name.trim().isEmpty) {
        throw const BusinessRuleFailure(message: 'O nome do fornecedor é obrigatório.');
      }
      await _repository.update(supplier);
      return true;
    });
  }
}
