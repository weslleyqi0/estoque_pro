import 'package:estoque_pro/app/core/utils/result.dart';
import 'package:estoque_pro/app/features/suppliers/domain/entities/supplier_entity.dart';
import 'package:estoque_pro/app/features/suppliers/domain/repositories/suppliers_repository.dart';

class SaveSupplierUseCase {
  final SuppliersRepository _repository;

  const SaveSupplierUseCase(this._repository);

  AsyncResult<bool> call(SupplierEntity supplier) async {
    if (supplier.name.trim().isEmpty) {
      return Result.failure(const BusinessRuleFailure(message: 'O nome do fornecedor é obrigatório.'));
    }
    final result = await _repository.save(supplier);
    return result.fold(
      onSuccess: (_) => const Result.success(true),
      onFailure: (error) => Result.failure(error),
    );
  }
}
