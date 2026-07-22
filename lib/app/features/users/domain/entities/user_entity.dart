import 'package:estoque_pro/app/features/users/domain/entities/user_permission.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_role.dart';

class UserEntity {
  final String uid;
  final String name;
  final String email;
  final UserRole role;
  final bool isActive;
  final Set<UserPermission> permissions;

  const UserEntity({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.isActive,
    required this.permissions,
  });

  bool hasPermission(UserPermission permission) {
    if (!isActive) return false;
    if (role == UserRole.owner) return true;
    return permissions.contains(permission);
  }
}
