import 'package:estoque_pro/app/core/utils/result.dart';
import 'package:estoque_pro/app/features/deliveries/domain/entities/delivery_entity.dart';
import 'package:estoque_pro/app/features/deliveries/domain/repositories/deliveries_repository.dart';
import 'package:estoque_pro/app/features/sales/domain/repositories/sales_repository.dart';
import 'package:flutter/foundation.dart';

class UpdateDeliveryUseCase {
  final DeliveriesRepository _repository;
  final SalesRepository? _salesRepository;

  const UpdateDeliveryUseCase(
    this._repository, [
    this._salesRepository,
  ]);

  AsyncResult<bool> call(DeliveryEntity delivery) async {
    if (delivery.id.trim().isEmpty) {
      return Result.failure(const BusinessRuleFailure(message: 'ID da entrega inválido.'));
    }
    if (delivery.customerAddress.trim().isEmpty) {
      return Result.failure(const BusinessRuleFailure(message: 'O endereço de entrega é obrigatório.'));
    }
    final result = await _repository.updateDelivery(delivery);
    return result.fold(
      onSuccess: (_) async {
        if (_salesRepository != null && delivery.saleId.isNotEmpty) {
          try {
            await _salesRepository.updateCustomer(
              delivery.saleId,
              customerId: delivery.customerId,
              customerName: delivery.customerName,
            );
          } catch (e, stack) {
            debugPrint('---> Sales: Erro ao sincronizar cliente na venda vinculada: $e\n$stack');
          }
        }
        return const Result.success(true);
      },
      onFailure: (error) => Result.failure(error),
    );
  }
}
