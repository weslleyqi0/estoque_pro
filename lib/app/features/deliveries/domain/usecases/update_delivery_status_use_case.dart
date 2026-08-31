import 'package:estoque_pro/app/core/utils/result.dart';
import 'package:estoque_pro/app/features/deliveries/domain/entities/delivery_status.dart';
import 'package:estoque_pro/app/features/deliveries/domain/repositories/deliveries_repository.dart';

class UpdateDeliveryStatusUseCase {
  final DeliveriesRepository _repository;

  const UpdateDeliveryStatusUseCase(this._repository);

  AsyncResult<bool> call(
    String deliveryId,
    DeliveryStatus status, {
    DateTime? deliveredAt,
  }) async {
    if (deliveryId.trim().isEmpty) {
      return Result.failure(const BusinessRuleFailure(message: 'ID da entrega inválido.'));
    }
    final result = await _repository.updateStatus(deliveryId, status, deliveredAt: deliveredAt);
    return result.fold(
      onSuccess: (_) => const Result.success(true),
      onFailure: (error) => Result.failure(error),
    );
  }
}
