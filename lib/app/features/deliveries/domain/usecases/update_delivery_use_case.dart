import 'package:estoque_pro/app/core/utils/result.dart';
import 'package:estoque_pro/app/features/deliveries/domain/entities/delivery_entity.dart';
import 'package:estoque_pro/app/features/deliveries/domain/repositories/deliveries_repository.dart';

class UpdateDeliveryUseCase {
  final DeliveriesRepository _repository;

  const UpdateDeliveryUseCase(this._repository);

  AsyncResult<bool> call(DeliveryEntity delivery) async {
    return Result.guard(() async {
      if (delivery.id.trim().isEmpty) {
        throw const BusinessRuleFailure(message: 'ID da entrega inválido.');
      }
      if (delivery.customerAddress.trim().isEmpty) {
        throw const BusinessRuleFailure(message: 'O endereço de entrega é obrigatório.');
      }
      await _repository.updateDelivery(delivery);
      return true;
    });
  }
}
