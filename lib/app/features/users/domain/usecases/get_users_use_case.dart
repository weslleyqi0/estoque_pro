import 'package:estoque_pro/app/core/utils/result.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_entity.dart';
import 'package:estoque_pro/app/features/users/domain/repositories/users_repository.dart';

class GetUsersUseCase {
  final UsersRepository _repository;

  const GetUsersUseCase(this._repository);

  Stream<Result<List<UserEntity>>> listenAllUsers() {
    return _repository.listenAllUsers();
  }

  Future<Result<List<UserEntity>>> getAllUsers() {
    return _repository.getAllUsers();
  }

  Future<Result<UserEntity?>> getUser(String uid) {
    return _repository.getUser(uid);
  }

  Stream<UserEntity?> listenUser(String uid) {
    return _repository.listenUser(uid);
  }
}
