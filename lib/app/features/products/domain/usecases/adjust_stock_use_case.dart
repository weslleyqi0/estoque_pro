import 'package:estoque_pro/app/core/utils/result.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_history_entity.dart';
import 'package:estoque_pro/app/features/products/domain/repositories/products_repository.dart';

class AdjustStockUseCase {
  final ProductsRepository _repository;

  const AdjustStockUseCase(this._repository);

  AsyncResult<bool> call({
    required String productId,
    required int quantityDiff,
    required ProductHistoryEntity history,
  }) async {
    return Result.guard(() async {
      if (productId.trim().isEmpty) {
        throw const BusinessRuleFailure(message: 'ID do produto inválido.');
      }
      if (quantityDiff == 0) {
        throw const BusinessRuleFailure(
          message: 'A quantidade de alteração de estoque não pode ser zero.',
        );
      }
      await _repository.adjustStock(productId, quantityDiff, history);
      return true;
    });
  }
}
