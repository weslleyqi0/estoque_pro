import 'package:estoque_pro/app/core/utils/result.dart';
import 'package:estoque_pro/app/features/customers/domain/entities/customer_payment_entity.dart';
import 'package:estoque_pro/app/features/customers/domain/repositories/customer_payments_repository.dart';

class RegisterCustomerPaymentUseCase {
  final CustomerPaymentsRepository _repository;

  const RegisterCustomerPaymentUseCase(this._repository);

  AsyncResult<bool> call(CustomerPaymentEntity payment) async {
    if (payment.customerId.trim().isEmpty) {
      return Result.failure(const BusinessRuleFailure(message: 'ID do cliente inválido.'));
    }
    if (payment.amount <= 0) {
      return Result.failure(const BusinessRuleFailure(message: 'O valor do pagamento deve ser maior que zero.'));
    }
    final result = await _repository.save(payment);
    return result.fold(
      onSuccess: (_) => const Result.success(true),
      onFailure: (error) => Result.failure(error),
    );
  }
}
