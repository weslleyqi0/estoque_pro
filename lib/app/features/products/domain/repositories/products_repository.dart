import 'package:estoque_pro/app/core/utils/result.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_entity.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_history_entity.dart';

abstract class ProductsRepository {
  Stream<List<ProductEntity>> watchAll();
  Future<Result<List<ProductEntity>>> getAll();
  Future<Result<void>> save(ProductEntity product);
  Future<Result<void>> update(ProductEntity product);
  Future<Result<void>> archive(String id);
  Future<Result<void>> unarchive(String id);
  Future<Result<void>> deletePermanently(String id);
  Future<Result<void>> adjustStock(String productId, int quantityDiff, ProductHistoryEntity history);
  Stream<List<ProductHistoryEntity>> watchHistory(String productId, {int limit});
  Future<Result<bool>> checkBarcodeExists(String barcode, {String? ignoreId});
}
