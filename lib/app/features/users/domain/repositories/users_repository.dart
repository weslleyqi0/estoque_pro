import 'package:estoque_pro/app/core/utils/result.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_entity.dart';

/// Repository responsible for CRUD operations and realtime updates of [UserEntity].
abstract class UsersRepository {
  /// Fetches a [UserEntity] by its [uid].
  ///
  /// Returns `null` if the user is not found.
  Future<Result<UserEntity?>> getUser(String uid);

  /// Listens to realtime changes for a specific user [uid].
  Stream<UserEntity?> listenUser(String uid);

  /// Saves or updates the provided [user] in the database.
  Future<Result<void>> saveUser(UserEntity user);

  /// Deletes the user identified by [uid] from the database.
  Future<Result<void>> deleteUser(String uid);

  /// Fetches all registered users from the database.
  Future<Result<List<UserEntity>>> getAllUsers();

  /// Listens to realtime changes across all registered users.
  Stream<Result<List<UserEntity>>> listenAllUsers();
}
