import 'package:estoque_pro/app/features/auth/domain/entities/user_entity.dart';

/// Repository responsible for CRUD operations and realtime updates of [UserEntity].
abstract class UserRepository {
  /// Fetches a [UserEntity] by its [uid].
  ///
  /// Returns `null` if the user is not found.
  Future<UserEntity?> getUser(String uid);

  /// Listens to realtime changes for a specific user [uid].
  Stream<UserEntity?> listenUser(String uid);

  /// Saves or updates the provided [user] in the database.
  Future<void> saveUser(UserEntity user);

  /// Deletes the user identified by [uid] from the database.
  Future<void> deleteUser(String uid);

  /// Fetches all registered users from the database.
  Future<List<UserEntity>> getAllUsers();

  /// Listens to realtime changes across all registered users.
  Stream<List<UserEntity>> listenAllUsers();
}
