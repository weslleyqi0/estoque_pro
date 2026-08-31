import 'package:estoque_pro/app/core/utils/result.dart';
import 'package:estoque_pro/app/features/suppliers/domain/repositories/suppliers_repository.dart';

class DeleteSupplierUseCase {
  final SuppliersRepository _repository;

  const DeleteSupplierUseCase(this._repository);

  AsyncResult<bool> call(String id) async {
    if (id.trim().isEmpty) {
      return Result.failure(const BusinessRuleFailure(message: 'ID do fornecedor inválido.'));
    }
    final result = await _repository.delete(id);
    return result.fold(
      onSuccess: (_) => const Result.success(true),
      onFailure: (error) => Result.failure(error),
    );
  }
}
