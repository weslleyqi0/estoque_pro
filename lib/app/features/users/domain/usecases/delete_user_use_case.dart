import 'package:estoque_pro/app/core/utils/result.dart';
import 'package:estoque_pro/app/features/users/domain/repositories/users_repository.dart';

class DeleteUserUseCase {
  final UsersRepository _repository;

  const DeleteUserUseCase(this._repository);

  AsyncResult<bool> call(String uid) async {
    return Result.guard(() async {
      if (uid.trim().isEmpty) {
        throw const BusinessRuleFailure(message: 'UID do usuário inválido.');
      }
      await _repository.deleteUser(uid);
      return true;
    });
  }
}
