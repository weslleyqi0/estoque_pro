import 'package:estoque_pro/app/features/customers/domain/entities/customer_payment_entity.dart';
import 'package:estoque_pro/app/features/customers/domain/repositories/customer_payments_repository.dart';

class GetCustomerPaymentsUseCase {
  final CustomerPaymentsRepository _repository;

  const GetCustomerPaymentsUseCase(this._repository);

  Stream<List<CustomerPaymentEntity>> watchAll() {
    return _repository.watchAll();
  }

  Future<List<CustomerPaymentEntity>> getAll() {
    return _repository.getAll();
  }
}
