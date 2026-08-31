import 'package:estoque_pro/app/core/utils/result.dart';
import 'package:estoque_pro/app/features/categories/domain/repositories/categories_repository.dart';

class DeleteCategoryUseCase {
  final CategoriesRepository _repository;

  const DeleteCategoryUseCase(this._repository);

  AsyncResult<bool> call(String id) async {
    if (id.trim().isEmpty) {
      return Result.failure(const BusinessRuleFailure(message: 'ID da categoria inválido.'));
    }
    final result = await _repository.delete(id);
    return result.fold(
      onSuccess: (_) => const Result.success(true),
      onFailure: (error) => Result.failure(error),
    );
  }
}
