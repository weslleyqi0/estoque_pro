import 'package:estoque_pro/app/core/utils/result.dart';
import 'package:estoque_pro/app/features/sales/domain/repositories/sales_repository.dart';

class DeleteSaleUseCase {
  final SalesRepository _repository;

  const DeleteSaleUseCase(this._repository);

  AsyncResult<bool> call(String saleId) async {
    if (saleId.trim().isEmpty) {
      return Result.failure(const BusinessRuleFailure(message: 'ID da venda inválido.'));
    }
    final result = await _repository.delete(saleId);
    return result.fold(
      onSuccess: (_) => const Result.success(true),
      onFailure: (error) => Result.failure(error),
    );
  }
}
