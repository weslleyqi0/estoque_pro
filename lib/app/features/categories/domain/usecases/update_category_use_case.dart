import 'package:estoque_pro/app/core/utils/result.dart';
import 'package:estoque_pro/app/features/categories/domain/entities/category_entity.dart';
import 'package:estoque_pro/app/features/categories/domain/repositories/categories_repository.dart';

class UpdateCategoryUseCase {
  final CategoriesRepository _repository;

  const UpdateCategoryUseCase(this._repository);

  AsyncResult<bool> call(CategoryEntity category) async {
    if (category.id.trim().isEmpty) {
      return Result.failure(const BusinessRuleFailure(message: 'ID da categoria inválido.'));
    }
    if (category.name.trim().isEmpty) {
      return Result.failure(const BusinessRuleFailure(message: 'O nome da categoria é obrigatório.'));
    }
    final result = await _repository.update(category);
    return result.fold(
      onSuccess: (_) => const Result.success(true),
      onFailure: (error) => Result.failure(error),
    );
  }
}
