import 'package:estoque_pro/app/features/products/domain/repositories/products_repository.dart';

class CountProductsUseCase {
  final ProductsRepository _productsRepository;

  const CountProductsUseCase(this._productsRepository);

  /// Stream de contagem de produtos por fornecedor
  Stream<int> countBySupplier(String supplierId) {
    return _productsRepository.watchAll().map(
      (products) => products.where((p) => p.supplier?.id == supplierId).length,
    );
  }

  /// Contagem one-shot por fornecedor
  Future<int> executeBySupplier(String supplierId) async {
    final products = await _productsRepository.getAll();
    return products.where((p) => p.supplier?.id == supplierId).length;
  }

  /// Stream de contagem de produtos por categoria
  Stream<int> countByCategory(String categoryId) {
    return _productsRepository.watchAll().map(
      (products) => products
          .where((p) => p.categories.any((c) => c.id == categoryId))
          .length,
    );
  }

  /// Contagem one-shot por categoria
  Future<int> executeByCategory(String categoryId) async {
    final products = await _productsRepository.getAll();
    return products.where((p) => p.categories.any((c) => c.id == categoryId)).length;
  }

  /// Stream de contagem de produtos com estoque baixo
  Stream<int> countLowStock() {
    return _productsRepository.watchAll().map(
      (products) =>
          products.where((p) => p.stock < p.minStock && p.isActive).length,
    );
  }
}