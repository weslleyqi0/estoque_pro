import 'package:estoque_pro/app/core/utils/result.dart';
import 'package:estoque_pro/app/features/customers/domain/entities/customer_entity.dart';

abstract class CustomersRepository {
  Stream<List<CustomerEntity>> watchAll();
  Future<Result<List<CustomerEntity>>> getAll();
  Future<Result<void>> save(CustomerEntity customer);
  Future<Result<void>> update(CustomerEntity customer);
  Future<Result<void>> delete(String id);
}
