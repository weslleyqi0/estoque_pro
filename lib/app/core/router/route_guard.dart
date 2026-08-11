import 'dart:async';
import 'package:estoque_pro/app/core/router/app_routes.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_role.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../features/users/domain/entities/user_entity.dart';
import '../../features/users/domain/entities/user_permission.dart';

class RouteGuard {
  final Map<String, UserPermission> routePermissions;
  final String inactiveRedirectPath;
  final String unauthorizedRedirectPath;

  const RouteGuard({
    required this.routePermissions,
    this.inactiveRedirectPath = AppRoutes.inactive,
    this.unauthorizedRedirectPath = AppRoutes.unauthorized,
  });

  FutureOr<String?> redirect(BuildContext context, GoRouterState state, UserEntity? user) {
    final path = state.uri.path;

    if (user != null) {
      if (!user.isActive) {
        if (path == inactiveRedirectPath) return null;
        return inactiveRedirectPath;
      }
    }

    if (user != null && (user.role == UserRole.owner || user.role == UserRole.admin)) {
      return null;
    }

    UserPermission? requiredPermission;
    for (final entry in routePermissions.entries) {
      if (path == entry.key || path.startsWith('${entry.key}/')) {
        requiredPermission = entry.value;
        break;
      }
    }

    if (requiredPermission != null) {
      if (user == null || !user.hasPermission(requiredPermission)) {
        return unauthorizedRedirectPath;
      }
    }

    return null;
  }
}
