import 'package:estoque_pro/app/features/products/domain/entities/product_entity.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_history_entity.dart';

abstract class ProductsRepository {
  Stream<List<ProductEntity>> watchAll();
  Future<List<ProductEntity>> getAll();
  Future<void> save(ProductEntity product);
  Future<void> update(ProductEntity product);
  Future<void> delete(String id);
  Future<void> adjustStock(String productId, int quantityDiff, ProductHistoryEntity history);
  Stream<List<ProductHistoryEntity>> watchHistory(String productId, {int limit});
}
