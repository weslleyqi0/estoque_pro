import 'package:estoque_pro/app/core/utils/result.dart';
import 'package:estoque_pro/app/features/customers/domain/entities/customer_payment_entity.dart';

abstract class CustomerPaymentsRepository {
  Stream<List<CustomerPaymentEntity>> watchAll();
  Future<Result<List<CustomerPaymentEntity>>> getAll();
  Future<Result<void>> save(CustomerPaymentEntity payment);
  Future<Result<void>> delete(String id);
}
