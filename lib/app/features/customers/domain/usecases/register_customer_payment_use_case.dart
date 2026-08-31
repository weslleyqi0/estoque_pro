import 'package:estoque_pro/app/core/utils/result.dart';
import 'package:estoque_pro/app/features/customers/domain/entities/customer_payment_entity.dart';
import 'package:estoque_pro/app/features/customers/domain/repositories/customer_payments_repository.dart';

class RegisterCustomerPaymentUseCase {
  final CustomerPaymentsRepository _repository;

  const RegisterCustomerPaymentUseCase(this._repository);

  AsyncResult<bool> call(CustomerPaymentEntity payment) async {
    return Result.guard(() async {
      if (payment.customerId.trim().isEmpty) {
        throw const BusinessRuleFailure(message: 'ID do cliente inválido.');
      }
      if (payment.amount <= 0) {
        throw const BusinessRuleFailure(message: 'O valor do pagamento deve ser maior que zero.');
      }
      await _repository.save(payment);
      return true;
    });
  }
}
