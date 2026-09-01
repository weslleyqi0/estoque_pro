import 'package:estoque_pro/app/core/utils/result.dart';
import 'package:estoque_pro/app/features/deliveries/domain/repositories/deliveries_repository.dart';

class DeleteDeliveryUseCase {
  final DeliveriesRepository _repository;

  const DeleteDeliveryUseCase(this._repository);

  AsyncResult<bool> call(String deliveryId) async {
    if (deliveryId.trim().isEmpty) {
      return Result.failure(const BusinessRuleFailure(message: 'ID da entrega inválido.'));
    }
    final result = await _repository.delete(deliveryId);
    return result.fold(
      onSuccess: (_) => const Result.success(true),
      onFailure: (error) => Result.failure(error),
    );
  }
}
