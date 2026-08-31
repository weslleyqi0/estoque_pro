import 'package:estoque_pro/app/core/utils/result.dart';
import 'package:estoque_pro/app/features/categories/domain/repositories/categories_repository.dart';

class DeleteCategoryUseCase {
  final CategoriesRepository _repository;

  const DeleteCategoryUseCase(this._repository);

  AsyncResult<bool> call(String id) async {
    return Result.guard(() async {
      if (id.trim().isEmpty) {
        throw const BusinessRuleFailure(message: 'ID da categoria inválido.');
      }
      await _repository.delete(id);
      return true;
    });
  }
}
