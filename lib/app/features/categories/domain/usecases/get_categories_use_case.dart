import 'package:estoque_pro/app/core/utils/result.dart';
import 'package:estoque_pro/app/features/categories/domain/entities/category_entity.dart';
import 'package:estoque_pro/app/features/categories/domain/repositories/categories_repository.dart';

class GetCategoriesUseCase {
  final CategoriesRepository _repository;

  const GetCategoriesUseCase(this._repository);

  Stream<List<CategoryEntity>> watchAll() {
    return _repository.watchAll();
  }

  Future<Result<List<CategoryEntity>>> getAll() {
    return _repository.getAll();
  }
}
