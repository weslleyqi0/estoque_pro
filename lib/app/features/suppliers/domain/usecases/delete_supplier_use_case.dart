import 'package:estoque_pro/app/core/utils/result.dart';
import 'package:estoque_pro/app/features/suppliers/domain/repositories/suppliers_repository.dart';

class DeleteSupplierUseCase {
  final SuppliersRepository _repository;

  const DeleteSupplierUseCase(this._repository);

  AsyncResult<bool> call(String id) async {
    return Result.guard(() async {
      if (id.trim().isEmpty) {
        throw const BusinessRuleFailure(message: 'ID do fornecedor inválido.');
      }
      await _repository.delete(id);
      return true;
    });
  }
}
