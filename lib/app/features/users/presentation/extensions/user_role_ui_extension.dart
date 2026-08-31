import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_role.dart';
import 'package:flutter/material.dart';

extension UserRoleUIExtension on UserRole {
  Color color(BuildContext context) => switch (this) {
        UserRole.owner => context.colorScheme.onSurface,
        UserRole.admin => const Color(0xFF0057C9),
        UserRole.seller => const Color(0xFF790098),
      };

  IconData get icon => switch (this) {
        UserRole.owner => AppIcons.crown,
        UserRole.admin => AppIcons.shieldPerson,
        UserRole.seller => AppIcons.shoppingBag,
      };
}
