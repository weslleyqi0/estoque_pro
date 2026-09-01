import 'package:estoque_pro/app/core/utils/result.dart';
import 'package:estoque_pro/app/features/products/domain/repositories/products_repository.dart';

class DeleteProductPermanentlyUseCase {
  final ProductsRepository _repository;

  const DeleteProductPermanentlyUseCase(this._repository);

  AsyncResult<bool> call(String id) async {
    if (id.trim().isEmpty) {
      return Result.failure(const BusinessRuleFailure(message: 'ID do produto inválido.'));
    }
    final result = await _repository.deletePermanently(id);
    return result.fold(
      onSuccess: (_) => const Result.success(true),
      onFailure: (error) => Result.failure(error),
    );
  }
}
