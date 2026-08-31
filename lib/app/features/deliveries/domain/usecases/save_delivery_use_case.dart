import 'package:estoque_pro/app/core/utils/result.dart';
import 'package:estoque_pro/app/features/deliveries/domain/entities/delivery_entity.dart';
import 'package:estoque_pro/app/features/deliveries/domain/repositories/deliveries_repository.dart';

class SaveDeliveryUseCase {
  final DeliveriesRepository _repository;

  const SaveDeliveryUseCase(this._repository);

  AsyncResult<bool> call(DeliveryEntity delivery) async {
    if (delivery.customerAddress.trim().isEmpty) {
      return Result.failure(const BusinessRuleFailure(message: 'O endereço de entrega é obrigatório.'));
    }
    final result = await _repository.save(delivery);
    return result.fold(
      onSuccess: (_) => const Result.success(true),
      onFailure: (error) => Result.failure(error),
    );
  }
}
