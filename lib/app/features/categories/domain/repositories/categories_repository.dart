import 'package:estoque_pro/app/features/categories/domain/entities/category_entity.dart';

abstract class CategoriesRepository {
  Stream<List<CategoryEntity>> watchAll();
  Future<List<CategoryEntity>> getAll();
  Future<void> save(CategoryEntity category);
  Future<void> update(CategoryEntity category);
  Future<void> delete(String id);
}
