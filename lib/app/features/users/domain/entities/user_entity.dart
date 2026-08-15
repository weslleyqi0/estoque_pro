import 'package:equatable/equatable.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_permission.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_role.dart';

class UserEntity extends Equatable {
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
    if (role == UserRole.owner || role == UserRole.admin) return true;
    return permissions.contains(permission);
  }

  UserEntity copyWith({
    String? uid,
    String? name,
    String? email,
    UserRole? role,
    bool? isActive,
    Set<UserPermission>? permissions,
  }) {
    return UserEntity(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      permissions: permissions ?? this.permissions,
    );
  }

  @override
  List<Object?> get props => [
    uid,
    name,
    email,
    role,
    isActive,
    permissions,
  ];
}
