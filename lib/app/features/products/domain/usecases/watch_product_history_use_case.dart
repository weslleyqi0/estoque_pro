import 'package:estoque_pro/app/features/products/domain/entities/product_history_entity.dart';
import 'package:estoque_pro/app/features/products/domain/repositories/products_repository.dart';

class WatchProductHistoryUseCase {
  final ProductsRepository _repository;

  const WatchProductHistoryUseCase(this._repository);

  Stream<List<ProductHistoryEntity>> call(String productId, {int limit = 100}) {
    return _repository.watchHistory(productId, limit: limit);
  }
}
