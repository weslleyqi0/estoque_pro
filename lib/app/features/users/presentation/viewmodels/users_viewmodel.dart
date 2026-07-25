import 'dart:async';

import 'package:estoque_pro/app/core/utils/command.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_entity.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_permission.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_role.dart';
import 'package:estoque_pro/app/features/users/domain/repositories/users_repository.dart';
import 'package:flutter/foundation.dart';

enum UsersLoadState { loading, success, failure }

class UsersViewModel extends ChangeNotifier {
  final UsersRepository _usersRepository;

  StreamSubscription<Result<List<UserEntity>>>? _usersSubscription;
  late final Command1<bool, UserEntity> updateUserProfileCommand;
  bool _hasSortedInitially = false;

  final ValueNotifier<String?> expandedUserId = ValueNotifier(null);

  UsersLoadState _state = UsersLoadState.loading;
  UsersLoadState get state => _state;

  List<UserEntity> _users = [];
  List<UserEntity> get users => _users;

  Object? _error;
  Object? get error => _error;

  UsersViewModel(
    this._usersRepository,
  ) {
    updateUserProfileCommand = Command1(_updateUser);
  }

  Future<Result<bool>> _updateUser(UserEntity userToUpdate) async {
    try {
      await _usersRepository.saveUser(userToUpdate);

      return const Success(true);
    } catch (e) {
      return Failure(Exception(e.toString()));
    }
  }

  void listenAllUsers() {
    _state = UsersLoadState.loading;
    _hasSortedInitially = false;
    notifyListeners();

    _usersSubscription?.cancel();
    _usersSubscription = _usersRepository.listenAllUsers().listen(
      (result) {
        result.fold(
          onSuccess: (usersList) {
            if (!_hasSortedInitially) {
              _users = _sortUsers(usersList);
              _hasSortedInitially = true;
            } else {
              _users = _updateUsersPreservingOrder(usersList);
            }
            _state = UsersLoadState.success;
            notifyListeners();
          },
          onFailure: (error) {
            _error = error;
            _state = UsersLoadState.failure;
            notifyListeners();
          },
        );
      },
    );
  }

  List<UserEntity> _sortUsers(List<UserEntity> users) {
    return List<UserEntity>.from(users)..sort((a, b) {
      if (a.role == UserRole.owner && b.role != UserRole.owner) return -1;
      if (b.role == UserRole.owner && a.role != UserRole.owner) return 1;

      final roleCompare = a.role.index.compareTo(b.role.index);
      if (roleCompare != 0) return roleCompare;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
  }

  List<UserEntity> _updateUsersPreservingOrder(List<UserEntity> newUsers) {
    final existingIndexMap = <String, int>{};
    for (var i = 0; i < _users.length; i++) {
      existingIndexMap[_users[i].uid] = i;
    }

    return List<UserEntity>.from(newUsers)..sort((a, b) {
      if (a.role == UserRole.owner && b.role != UserRole.owner) return -1;
      if (b.role == UserRole.owner && a.role != UserRole.owner) return 1;

      final indexA = existingIndexMap[a.uid] ?? 999999;
      final indexB = existingIndexMap[b.uid] ?? 999999;

      if (indexA != indexB) {
        return indexA.compareTo(indexB);
      }

      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
  }

  void toggleExpanded(String userId) {
    expandedUserId.value = expandedUserId.value == userId ? null : userId;
  }

  void toggleUserPermission(UserEntity user, UserPermission permission) {
    final updatedPermissions = Set<UserPermission>.from(user.permissions);
    if (updatedPermissions.contains(permission)) {
      updatedPermissions.remove(permission);
    } else {
      updatedPermissions.add(permission);
    }
    updateUserProfileCommand.execute(user.copyWith(permissions: updatedPermissions));
  }

  void toggleUserActive(UserEntity user, bool isActive) {
    updateUserProfileCommand.execute(user.copyWith(isActive: isActive));
  }

  void updateUserRole(UserEntity user, UserRole role) {
    updateUserProfileCommand.execute(user.copyWith(role: role));
  }

  @override
  void dispose() {
    _usersSubscription?.cancel();
    expandedUserId.dispose();
    super.dispose();
  }
}
