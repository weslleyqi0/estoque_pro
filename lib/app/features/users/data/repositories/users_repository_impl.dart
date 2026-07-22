import 'dart:async';

import 'package:estoque_pro/app/core/services/firebase_database_service.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_entity.dart';
import 'package:estoque_pro/app/features/users/data/models/user_model.dart';
import 'package:estoque_pro/app/features/users/domain/repositories/users_repository.dart';

class UsersRepositoryImpl implements UsersRepository {
  final FirebaseDatabaseService<UserEntity> _usersDatabase;

  UsersRepositoryImpl(
    this._usersDatabase,
  );

  @override
  Future<UserEntity?> getUser(String uid) async {
    final snapshotValue = await _usersDatabase.getChildOnce(uid).timeout(const Duration(seconds: 4));

    if (snapshotValue != null) {
      return UserModel.fromMap(uid, snapshotValue);
    }
    return null;
  }

  @override
  Stream<UserEntity?> listenUser(String uid) {
    return _usersDatabase.listenChild(uid).map((data) {
      if (data != null) {
        return UserModel.fromMap(uid, data);
      }
      return null;
    });
  }

  @override
  Future<void> saveUser(UserEntity user) async {
    final model = UserModel.fromEntity(user);
    await _usersDatabase.update(user.uid, model.toMap()).timeout(const Duration(seconds: 4));
  }

  @override
  Future<void> deleteUser(String uid) async {
    await _usersDatabase.delete(uid).timeout(const Duration(seconds: 4));
  }

  @override
  Future<List<UserEntity>> getAllUsers() async {
    final data = await _usersDatabase.getOnce().timeout(const Duration(seconds: 4));
    if (data != null) {
      final usersList = <UserEntity>[];
      data.forEach((key, value) {
        if (value is Map) {
          usersList.add(UserModel.fromMap(key.toString(), value));
        }
      });
      return usersList;
    }
    return [];
  }

  @override
  Stream<List<UserEntity>> listenAllUsers() {
    return _usersDatabase.listen().map((data) {
      final usersList = <UserEntity>[];
      if (data != null) {
        data.forEach((key, value) {
          if (value is Map) {
            usersList.add(UserModel.fromMap(key.toString(), value));
          }
        });
      }
      return usersList;
    });
  }
}
