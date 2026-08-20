import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_role.dart';
import 'package:flutter/material.dart';

extension UserRoleUIExtension on UserRole {
  Color color(BuildContext context) {
    switch (this) {
      case UserRole.owner:
        return context.colorScheme.onSurface;
      case UserRole.admin:
        return const Color(0xFF0057C9);
      case UserRole.seller:
        return const Color(0xFF790098);
    }
  }

  IconData get icon {
    switch (this) {
      case UserRole.owner:
        return AppIcons.crown;
      case UserRole.admin:
        return AppIcons.shieldPerson;
      case UserRole.seller:
        return AppIcons.shoppingBag;
    }
  }
}
