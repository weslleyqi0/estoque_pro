import 'package:estoque_pro/app/core/utils/result.dart';
import 'package:estoque_pro/app/features/customers/domain/entities/customer_entity.dart';
import 'package:estoque_pro/app/features/customers/domain/repositories/customers_repository.dart';

class SaveCustomerUseCase {
  final CustomersRepository _repository;

  const SaveCustomerUseCase(this._repository);

  AsyncResult<bool> call(CustomerEntity customer) async {
    if (customer.name.trim().isEmpty) {
      return Result.failure(const BusinessRuleFailure(message: 'O nome do cliente é obrigatório.'));
    }
    final result = await _repository.save(customer);
    return result.fold(
      onSuccess: (_) => const Result.success(true),
      onFailure: (error) => Result.failure(error),
    );
  }
}
