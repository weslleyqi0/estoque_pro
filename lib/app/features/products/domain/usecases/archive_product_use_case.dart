import 'package:estoque_pro/app/core/utils/result.dart';
import 'package:estoque_pro/app/features/products/domain/repositories/products_repository.dart';

class ArchiveProductUseCase {
  final ProductsRepository _repository;

  const ArchiveProductUseCase(this._repository);

  AsyncResult<bool> call(String id) async {
    return Result.guard(() async {
      if (id.trim().isEmpty) {
        throw const BusinessRuleFailure(message: 'ID do produto inválido.');
      }
      await _repository.archive(id);
      return true;
    });
  }
}
