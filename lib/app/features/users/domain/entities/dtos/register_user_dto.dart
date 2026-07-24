import 'package:estoque_pro/app/features/users/domain/entities/user_permission.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_role.dart';

class RegisterUserDto {
  final String name;
  final String email;
  final String password;
  final UserRole role;
  final bool isActive;
  final List<UserPermission> permissions;

  const RegisterUserDto({
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    required this.isActive,
    required this.permissions,
  });
}
