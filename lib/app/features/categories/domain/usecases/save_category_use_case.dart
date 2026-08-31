import 'package:estoque_pro/app/core/utils/result.dart';
import 'package:estoque_pro/app/features/categories/domain/entities/category_entity.dart';
import 'package:estoque_pro/app/features/categories/domain/repositories/categories_repository.dart';

class SaveCategoryUseCase {
  final CategoriesRepository _repository;

  const SaveCategoryUseCase(this._repository);

  AsyncResult<bool> call(CategoryEntity category) async {
    return Result.guard(() async {
      if (category.name.trim().isEmpty) {
        throw const BusinessRuleFailure(message: 'O nome da categoria é obrigatório.');
      }
      await _repository.save(category);
      return true;
    });
  }
}
