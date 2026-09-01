import 'package:estoque_pro/app/core/utils/result.dart';
import 'package:estoque_pro/app/features/categories/domain/entities/category_entity.dart';

abstract class CategoriesRepository {
  Stream<List<CategoryEntity>> watchAll();
  Future<Result<List<CategoryEntity>>> getAll();
  Future<Result<void>> save(CategoryEntity category);
  Future<Result<void>> update(CategoryEntity category);
  Future<Result<void>> delete(String id);
}
