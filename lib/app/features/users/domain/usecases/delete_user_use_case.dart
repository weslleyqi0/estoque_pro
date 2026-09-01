import 'package:estoque_pro/app/core/utils/result.dart';
import 'package:estoque_pro/app/features/users/domain/repositories/users_repository.dart';

class DeleteUserUseCase {
  final UsersRepository _repository;

  const DeleteUserUseCase(this._repository);

  AsyncResult<bool> call(String uid) async {
    if (uid.trim().isEmpty) {
      return Result.failure(const BusinessRuleFailure(message: 'UID do usuário inválido.'));
    }
    final result = await _repository.deleteUser(uid);
    return result.fold(
      onSuccess: (_) => const Result.success(true),
      onFailure: (error) => Result.failure(error),
    );
  }
}
