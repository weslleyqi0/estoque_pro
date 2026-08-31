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
    if (productId.trim().isEmpty) {
      return Result.failure(const BusinessRuleFailure(message: 'ID do produto inválido.'));
    }
    if (quantityDiff == 0) {
      return Result.failure(
        const BusinessRuleFailure(
          message: 'A quantidade de alteração de estoque não pode ser zero.',
        ),
      );
    }
    final result = await _repository.adjustStock(productId, quantityDiff, history);
    return result.fold(
      onSuccess: (_) => const Result.success(true),
      onFailure: (error) => Result.failure(error),
    );
  }
}
