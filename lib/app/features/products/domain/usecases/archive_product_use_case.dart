import 'package:estoque_pro/app/core/utils/result.dart';
import 'package:estoque_pro/app/features/products/domain/repositories/products_repository.dart';

class ArchiveProductUseCase {
  final ProductsRepository _repository;

  const ArchiveProductUseCase(this._repository);

  AsyncResult<bool> call(String id) async {
    if (id.trim().isEmpty) {
      return Result.failure(const BusinessRuleFailure(message: 'ID do produto inválido.'));
    }
    final result = await _repository.archive(id);
    return result.fold(
      onSuccess: (_) => const Result.success(true),
      onFailure: (error) => Result.failure(error),
    );
  }
}
