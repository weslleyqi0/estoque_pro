import 'package:estoque_pro/app/features/customers/domain/entities/customer_payment_entity.dart';

abstract class CustomerPaymentsRepository {
  Stream<List<CustomerPaymentEntity>> watchAll();
  Future<List<CustomerPaymentEntity>> getAll();
  Future<void> save(CustomerPaymentEntity payment);
  Future<void> delete(String id);
}
