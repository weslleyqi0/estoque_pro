import 'package:estoque_pro/app/core/utils/result.dart';
import 'package:estoque_pro/app/features/customers/domain/repositories/customers_repository.dart';

class DeleteCustomerUseCase {
  final CustomersRepository _repository;

  const DeleteCustomerUseCase(this._repository);

  AsyncResult<bool> call(String id) async {
    if (id.trim().isEmpty) {
      return Result.failure(const BusinessRuleFailure(message: 'ID do cliente inválido.'));
    }
    final result = await _repository.delete(id);
    return result.fold(
      onSuccess: (_) => const Result.success(true),
      onFailure: (error) => Result.failure(error),
    );
  }
}
