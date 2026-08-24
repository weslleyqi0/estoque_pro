import 'package:estoque_pro/app/features/customers/domain/entities/customer_entity.dart';

abstract class CustomersRepository {
  Stream<List<CustomerEntity>> watchAll();
  Future<List<CustomerEntity>> getAll();
  Future<void> save(CustomerEntity customer);
  Future<void> update(CustomerEntity customer);
  Future<void> delete(String id);
}
