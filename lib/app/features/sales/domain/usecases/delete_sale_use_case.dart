import 'package:estoque_pro/app/core/utils/result.dart';
import 'package:estoque_pro/app/features/sales/domain/repositories/sales_repository.dart';

class DeleteSaleUseCase {
  final SalesRepository _repository;

  const DeleteSaleUseCase(this._repository);

  AsyncResult<bool> call(String saleId) async {
    return Result.guard(() async {
      if (saleId.trim().isEmpty) {
        throw const BusinessRuleFailure(message: 'ID da venda inválido.');
      }
      await _repository.delete(saleId);
      return true;
    });
  }
}
