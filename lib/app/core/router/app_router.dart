import 'package:estoque_pro/app/core/di/service_locator.dart';
import 'package:estoque_pro/app/features/auth/presentation/pages/biometric_page.dart';
import 'package:estoque_pro/app/features/auth/presentation/pages/login_page.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/biometric_viewmodel.dart';
import 'package:estoque_pro/app/features/home/presentation/home_page.dart';
import 'package:estoque_pro/app/features/users/presentation/pages/users_page.dart';
import 'package:estoque_pro/app/features/users/presentation/viewmodels/users_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    refreshListenable: getIt<AuthViewModel>(),
    redirect: (context, state) {
      final authViewModel = getIt<AuthViewModel>();
      final user = authViewModel.currentUser;
      final isBiometricAuth = authViewModel.isBiometricAuthenticated;

      final isLoginPage = state.uri.toString() == '/login';
      final isBiometricPage = state.uri.toString() == '/biometric';

      if (user == null) {
        return isLoginPage ? null : '/login';
      }

      if (!isBiometricAuth) {
        return isBiometricPage ? null : '/biometric';
      }

      if (isLoginPage || isBiometricPage) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginPage(viewModel: getIt<AuthViewModel>()),
      ),
      GoRoute(
        path: '/biometric',
        builder: (context, state) => BiometricPage(viewModel: getIt<BiometricViewModel>()),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/users',
        builder: (context, state) => UsersPage(viewModel: getIt<UsersViewModel>()),
      ),
    ],
  );
}
