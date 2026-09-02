import 'dart:async';

import 'package:estoque_pro/app/core/router/app_routes.dart';
import 'package:estoque_pro/app/core/router/route_guard.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_permission.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_role.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

class AuthRedirectPolicy {
  final RouteGuard routeGuard;

  const AuthRedirectPolicy({
    this.routeGuard = const RouteGuard(
      routePermissions: {
        AppRoutes.productHistory: UserPermission.viewHistory,
        AppRoutes.supplierForm: UserPermission.manageSuppliers,
        AppRoutes.customerForm: UserPermission.managerCustomer,
        AppRoutes.categoryForm: UserPermission.manageCategories,
        AppRoutes.deliveries: UserPermission.deliveries,
        AppRoutes.reports: UserPermission.viewReports,
      },
    ),
  });

  FutureOr<String?> resolveRedirect(
    BuildContext context,
    GoRouterState state,
    AuthViewModel authViewModel,
  ) {
    final isAuthenticated = authViewModel.isAuthenticated;
    final isBiometricAuth = authViewModel.isBiometricAuthenticated;
    final currentUser = authViewModel.currentUser;

    final path = state.uri.path;
    final isLoginPage = path == AppRoutes.login;
    final isBiometricPage = path == AppRoutes.biometric;
    final isInactivePage = path == AppRoutes.inactive;

    if (!isAuthenticated) {
      return isLoginPage ? null : AppRoutes.login;
    }

    if (currentUser != null && !currentUser.isActive) {
      return isInactivePage ? null : AppRoutes.inactive;
    }

    if (isLoginPage) {
      return isBiometricAuth ? AppRoutes.home : AppRoutes.biometric;
    }

    if (isInactivePage) {
      return AppRoutes.home;
    }

    if (!isBiometricAuth && !isBiometricPage) {
      return AppRoutes.biometric;
    }

    if (isBiometricAuth && isBiometricPage) {
      return AppRoutes.home;
    }

    if (path.startsWith(AppRoutes.users) && currentUser?.role == UserRole.seller) {
      return AppRoutes.unauthorized;
    }

    return routeGuard.redirect(context, state, currentUser);
  }
}
