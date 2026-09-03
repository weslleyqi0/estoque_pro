import 'package:estoque_pro/app/core/utils/result.dart';
import 'package:estoque_pro/app/features/deliveries/domain/repositories/deliveries_repository.dart';
import 'package:estoque_pro/app/features/sales/domain/repositories/sales_repository.dart';
import 'package:flutter/foundation.dart';

class DeleteSaleUseCase {
  final SalesRepository _repository;
  final DeliveriesRepository? _deliveriesRepository;

  const DeleteSaleUseCase(
    this._repository, [
    this._deliveriesRepository,
  ]);

  AsyncResult<bool> call(String saleId) async {
    if (saleId.trim().isEmpty) {
      return Result.failure(const BusinessRuleFailure(message: 'ID da venda inválido.'));
    }
    final result = await _repository.delete(saleId);
    return result.fold(
      onSuccess: (_) async {
        if (_deliveriesRepository != null) {
          try {
            await _deliveriesRepository.cancelDeliveryForSale(saleId);
          } catch (e, stack) {
            debugPrint('---> Deliveries: Erro ao cancelar entrega da venda excluída: $e\n$stack');
          }
        }
        return const Result.success(true);
      },
      onFailure: (error) => Result.failure(error),
    );
  }
}
