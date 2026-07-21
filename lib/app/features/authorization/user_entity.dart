import 'package:estoque_pro/app/features/authorization/domain/entities/app_permission.dart';
import 'package:estoque_pro/app/features/authorization/domain/entities/app_role.dart';

class UserEntity {
  final String uid;
  final String name;
  final String email;
  final AppRole role;
  final bool isActive;
  final List<AppPermission> permissions;

  const UserEntity({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.isActive,
    required this.permissions,
  });

  bool hasPermission(AppPermission permission) {
    if (!isActive) return false;
    if (role == AppRole.owner) return true;
    return permissions.contains(permission);
  }
}
