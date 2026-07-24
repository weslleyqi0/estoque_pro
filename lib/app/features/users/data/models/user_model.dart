import 'package:estoque_pro/app/features/users/domain/entities/user_entity.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_permission.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_role.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role;
  final bool isActive;
  final Map<String, bool> permissions;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.isActive,
    required this.permissions,
  });

  factory UserModel.fromMap(String uid, Map<dynamic, dynamic> map) {
    final name = map['name'] as String? ?? '';
    final roleStr = map['role'] as String? ?? '';
    final email = map['email'] as String? ?? '';
    final isActive = map['isActive'] as bool? ?? true;

    final permsMap = <String, bool>{};
    final rawPerms = map['permissions'];
    if (rawPerms is Map) {
      rawPerms.forEach((key, value) {
        if (value == true) {
          permsMap[key.toString()] = true;
        }
      });
    }

    return UserModel(
      uid: uid,
      name: name,
      email: email,
      role: roleStr,
      isActive: isActive,
      permissions: permsMap,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'isActive': isActive,
      'permissions': permissions,
    };
  }

  UserEntity toEntity() {
    final permissionsSet = <UserPermission>{};
    permissions.forEach((key, value) {
      if (value) {
        final perm = UserPermission.fromValue(key);
        if (perm != null) {
          permissionsSet.add(perm);
        }
      }
    });

    return UserEntity(
      uid: uid,
      name: name,
      email: email,
      role: UserRole.fromValue(role) ?? UserRole.seller,
      isActive: isActive,
      permissions: permissionsSet,
    );
  }

  factory UserModel.fromEntity(UserEntity entity) {
    final permsMap = <String, bool>{};
    for (final perm in entity.permissions) {
      permsMap[perm.value] = true;
    }

    return UserModel(
      uid: entity.uid,
      name: entity.name,
      email: entity.email,
      role: entity.role.value,
      isActive: entity.isActive,
      permissions: permsMap,
    );
  }
}
