import 'package:estoque_pro/app/core/utils/result.dart';
import 'package:estoque_pro/app/features/deliveries/domain/entities/delivery_entity.dart';
import 'package:estoque_pro/app/features/deliveries/domain/repositories/deliveries_repository.dart';

class SaveDeliveryUseCase {
  final DeliveriesRepository _repository;

  const SaveDeliveryUseCase(this._repository);

  AsyncResult<bool> call(DeliveryEntity delivery) async {
    return Result.guard(() async {
      if (delivery.customerAddress.trim().isEmpty) {
        throw const BusinessRuleFailure(message: 'O endereço de entrega é obrigatório.');
      }
      await _repository.save(delivery);
      return true;
    });
  }
}
