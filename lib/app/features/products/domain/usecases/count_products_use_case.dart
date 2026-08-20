import 'package:estoque_pro/app/features/products/domain/repositories/products_repository.dart';

class CountProductsUseCase {
  final ProductsRepository _productsRepository;

  const CountProductsUseCase(this._productsRepository);

  /// Stream of product count by supplier
  Stream<int> countBySupplier(String supplierId) {
    return _productsRepository.watchAll().map(
      (products) => products.where((p) => p.supplier?.id == supplierId).length,
    );
  }

  /// One-shot product count by supplier
  Future<int> executeBySupplier(String supplierId) async {
    final products = await _productsRepository.getAll();
    return products.where((p) => p.supplier?.id == supplierId).length;
  }

  /// Stream of product count by category
  Stream<int> countByCategory(String categoryId) {
    return _productsRepository.watchAll().map(
      (products) => products.where((p) => p.categories.any((c) => c.id == categoryId)).length,
    );
  }

  /// One-shot product count by category
  Future<int> executeByCategory(String categoryId) async {
    final products = await _productsRepository.getAll();
    return products.where((p) => p.categories.any((c) => c.id == categoryId)).length;
  }

  /// Stream of low-stock product count
  Stream<int> countLowStock() {
    return _productsRepository.watchAll().map(
      (products) => products.where((p) => p.stock < p.minStock && p.isActive).length,
    );
  }
}
