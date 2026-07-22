import 'package:estoque_pro/app/features/users/domain/entities/user_entity.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_permission.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_role.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.name,
    required super.email,
    required super.role,
    required super.isActive,
    required super.permissions,
  });

  factory UserModel.fromEntity(UserEntity user) {
    return UserModel(
      uid: user.uid,
      name: user.name,
      email: user.email,
      role: user.role,
      isActive: user.isActive,
      permissions: user.permissions,
    );
  }

  factory UserModel.fromMap(String uid, Map<dynamic, dynamic> map) {
    final name = map['name'] as String? ?? '';
    final roleStr = map['role'] as String? ?? '';
    final role = UserRole.fromValue(roleStr) ?? UserRole.seller;
    final email = map['email'] as String? ?? '';
    final isActive = map['isActive'] as bool? ?? true;

    final permissionsList = <UserPermission>[];
    final permsMap = map['permissions'];
    if (permsMap is Map) {
      permsMap.forEach((key, value) {
        if (value == true) {
          final perm = UserPermission.fromValue(key.toString());
          if (perm != null) {
            permissionsList.add(perm);
          }
        }
      });
    }

    return UserModel(
      uid: uid,
      name: name,
      email: email,
      role: role,
      isActive: isActive,
      permissions: permissionsList.toSet(),
    );
  }

  Map<String, dynamic> toMap() {
    final permsMap = <String, bool>{};
    for (final perm in permissions) {
      permsMap[perm.value] = true;
    }
    return {
      'name': name,
      'email': email,
      'role': role.value,
      'isActive': isActive,
      'permissions': permsMap,
    };
  }
}
