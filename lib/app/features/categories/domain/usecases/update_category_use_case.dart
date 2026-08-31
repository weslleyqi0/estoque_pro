import 'package:estoque_pro/app/core/utils/result.dart';
import 'package:estoque_pro/app/features/categories/domain/entities/category_entity.dart';
import 'package:estoque_pro/app/features/categories/domain/repositories/categories_repository.dart';

class UpdateCategoryUseCase {
  final CategoriesRepository _repository;

  const UpdateCategoryUseCase(this._repository);

  AsyncResult<bool> call(CategoryEntity category) async {
    return Result.guard(() async {
      if (category.id.trim().isEmpty) {
        throw const BusinessRuleFailure(message: 'ID da categoria inválido.');
      }
      if (category.name.trim().isEmpty) {
        throw const BusinessRuleFailure(message: 'O nome da categoria é obrigatório.');
      }
      await _repository.update(category);
      return true;
    });
  }
}
