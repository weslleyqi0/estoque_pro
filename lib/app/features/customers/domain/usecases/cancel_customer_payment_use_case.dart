import 'package:estoque_pro/app/core/utils/result.dart';
import 'package:estoque_pro/app/features/customers/domain/entities/customer_payment_entity.dart';
import 'package:estoque_pro/app/features/customers/domain/repositories/customer_payments_repository.dart';

class CancelCustomerPaymentUseCase {
  final CustomerPaymentsRepository _repository;

  const CancelCustomerPaymentUseCase(this._repository);

  AsyncResult<bool> call(CustomerPaymentEntity payment, {required String reason}) async {
    final trimmedReason = reason.trim();
    if (trimmedReason.isEmpty) {
      return Result.failure(
        const BusinessRuleFailure(
          message: 'Informe o motivo ou uma observação para cancelar o pagamento.',
        ),
      );
    }
    final updated = payment.copyWith(
      isCancelled: true,
      cancelledAt: DateTime.now(),
      cancellationReason: trimmedReason,
    );
    final result = await _repository.save(updated);
    return result.fold(
      onSuccess: (_) => const Result.success(true),
      onFailure: (error) => Result.failure(error),
    );
  }
}
