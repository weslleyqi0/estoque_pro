import 'package:estoque_pro/app/features/products/domain/entities/product_entity.dart';
import 'package:estoque_pro/app/features/products/domain/repositories/products_repository.dart';

class GetProductsUseCase {
  final ProductsRepository _repository;

  const GetProductsUseCase(this._repository);

  Stream<List<ProductEntity>> watchAll() => _repository.watchAll();

  Future<List<ProductEntity>> getAll() => _repository.getAll();
}
