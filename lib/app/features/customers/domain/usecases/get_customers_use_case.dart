import 'package:estoque_pro/app/features/customers/domain/entities/customer_entity.dart';
import 'package:estoque_pro/app/features/customers/domain/repositories/customers_repository.dart';

class GetCustomersUseCase {
  final CustomersRepository _repository;

  const GetCustomersUseCase(this._repository);

  Stream<List<CustomerEntity>> watchAll() {
    return _repository.watchAll();
  }

  Future<List<CustomerEntity>> getAll() {
    return _repository.getAll();
  }
}
