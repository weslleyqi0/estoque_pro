import 'package:estoque_pro/app/core/utils/result.dart';
import 'package:estoque_pro/app/features/suppliers/domain/entities/supplier_entity.dart';
import 'package:estoque_pro/app/features/suppliers/domain/repositories/suppliers_repository.dart';

class SaveSupplierUseCase {
  final SuppliersRepository _repository;

  const SaveSupplierUseCase(this._repository);

  AsyncResult<bool> call(SupplierEntity supplier) async {
    return Result.guard(() async {
      if (supplier.name.trim().isEmpty) {
        throw const BusinessRuleFailure(message: 'O nome do fornecedor é obrigatório.');
      }
      await _repository.save(supplier);
      return true;
    });
  }
}
