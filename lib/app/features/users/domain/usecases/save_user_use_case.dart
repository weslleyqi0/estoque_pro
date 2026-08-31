import 'package:estoque_pro/app/core/utils/result.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_entity.dart';
import 'package:estoque_pro/app/features/users/domain/repositories/users_repository.dart';

class SaveUserUseCase {
  final UsersRepository _repository;

  const SaveUserUseCase(this._repository);

  AsyncResult<bool> call(UserEntity user) async {
    if (user.uid.trim().isEmpty) {
      return Result.failure(const BusinessRuleFailure(message: 'UID do usuário inválido.'));
    }
    if (user.name.trim().isEmpty) {
      return Result.failure(const BusinessRuleFailure(message: 'O nome do usuário é obrigatório.'));
    }
    if (user.email.trim().isEmpty) {
      return Result.failure(const BusinessRuleFailure(message: 'O e-mail do usuário é obrigatório.'));
    }
    final result = await _repository.saveUser(user);
    return result.fold(
      onSuccess: (_) => const Result.success(true),
      onFailure: (error) => Result.failure(error),
    );
  }
}
