import 'package:estoque_pro/app/core/utils/result.dart';
import 'package:estoque_pro/app/features/products/domain/repositories/products_repository.dart';

class DeleteProductPermanentlyUseCase {
  final ProductsRepository _repository;

  const DeleteProductPermanentlyUseCase(this._repository);

  AsyncResult<bool> call(String id) async {
    return Result.guard(() async {
      if (id.trim().isEmpty) {
        throw const BusinessRuleFailure(message: 'ID do produto inválido.');
      }
      await _repository.deletePermanently(id);
      return true;
    });
  }
}
