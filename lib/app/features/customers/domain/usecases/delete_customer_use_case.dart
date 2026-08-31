import 'package:estoque_pro/app/core/utils/result.dart';
import 'package:estoque_pro/app/features/customers/domain/repositories/customers_repository.dart';

class DeleteCustomerUseCase {
  final CustomersRepository _repository;

  const DeleteCustomerUseCase(this._repository);

  AsyncResult<bool> call(String id) async {
    return Result.guard(() async {
      if (id.trim().isEmpty) {
        throw const BusinessRuleFailure(message: 'ID do cliente inválido.');
      }
      await _repository.delete(id);
      return true;
    });
  }
}
