import 'dart:async';

import 'package:estoque_pro/app/core/services/database_service.dart';
import 'package:estoque_pro/app/core/utils/result.dart';
import 'package:estoque_pro/app/features/users/data/models/user_model.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_entity.dart';
import 'package:estoque_pro/app/features/users/domain/repositories/users_repository.dart';

class UsersRepositoryImpl implements UsersRepository {
  final DatabaseService<UserEntity> _usersDatabase;

  UsersRepositoryImpl(
    this._usersDatabase,
  );

  @override
  Future<Result<UserEntity?>> getUser(String uid) async {
    try {
      final snapshotValue = await _usersDatabase.getChildOnce(uid).timeout(const Duration(seconds: 4));

      if (snapshotValue != null) {
        return Result.success(UserModel.fromMap(uid, snapshotValue).toEntity());
      }
      return const Result.success(null);
    } catch (e, stackTrace) {
      return Result.failure(e, stackTrace);
    }
  }

  @override
  Stream<UserEntity?> listenUser(String uid) {
    return _usersDatabase.listenChild(uid).map((data) {
      if (data != null) {
        return UserModel.fromMap(uid, data).toEntity();
      }
      return null;
    });
  }

  @override
  Future<Result<void>> saveUser(UserEntity user) async {
    try {
      final model = UserModel.fromEntity(user);
      final updates = <String, dynamic>{
        'users/${user.uid}': model.toMap(),
        'user_roles/${user.uid}': user.role.value,
        'user_permissions/${user.uid}': model.permissions,
      };
      await _usersDatabase.updateMultiple(updates).timeout(const Duration(seconds: 4));
      return const Result.success(null);
    } catch (e, stackTrace) {
      return Result.failure(e, stackTrace);
    }
  }

  @override
  Future<Result<void>> deleteUser(String uid) async {
    try {
      final updates = <String, dynamic>{
        'users/$uid': null,
        'user_roles/$uid': null,
        'user_permissions/$uid': null,
      };
      await _usersDatabase.updateMultiple(updates).timeout(const Duration(seconds: 4));
      return const Result.success(null);
    } catch (e, stackTrace) {
      return Result.failure(e, stackTrace);
    }
  }

  @override
  Future<Result<List<UserEntity>>> getAllUsers() async {
    try {
      final data = await _usersDatabase.getOnce().timeout(const Duration(seconds: 4));
      if (data != null) {
        final usersList = <UserEntity>[];
        data.forEach((key, value) {
          if (value is Map) {
            usersList.add(UserModel.fromMap(key.toString(), value).toEntity());
          }
        });
        return Result.success(usersList);
      }
      return const Result.success([]);
    } catch (e, stackTrace) {
      return Result.failure(e, stackTrace);
    }
  }

  @override
  Stream<Result<List<UserEntity>>> listenAllUsers() {
    return _usersDatabase
        .listen()
        .map<Result<List<UserEntity>>>((data) {
          try {
            final usersList = <UserEntity>[];
            if (data != null) {
              data.forEach((key, value) {
                if (value is Map) {
                  usersList.add(UserModel.fromMap(key.toString(), value).toEntity());
                }
              });
            }
            return Result.success(usersList);
          } catch (e) {
            return Result.failure(e);
          }
        })
        .handleError((error) {
          return Result.failure(error);
        });
  }
}
