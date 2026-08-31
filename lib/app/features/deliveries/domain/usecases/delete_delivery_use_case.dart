import 'package:estoque_pro/app/core/utils/result.dart';
import 'package:estoque_pro/app/features/deliveries/domain/repositories/deliveries_repository.dart';

class DeleteDeliveryUseCase {
  final DeliveriesRepository _repository;

  const DeleteDeliveryUseCase(this._repository);

  AsyncResult<bool> call(String deliveryId) async {
    return Result.guard(() async {
      if (deliveryId.trim().isEmpty) {
        throw const BusinessRuleFailure(message: 'ID da entrega inválido.');
      }
      await _repository.delete(deliveryId);
      return true;
    });
  }
}
