import 'package:estoque_pro/app/core/di/service_locator.dart';
import 'package:estoque_pro/app/features/home/presentation/home_page.dart';
import 'package:estoque_pro/app/features/auth/presentation/pages/biometric_page.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/biometric_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    refreshListenable: getIt<BiometricViewModel>(),
    redirect: (context, state) {
      final biometricVM = getIt<BiometricViewModel>();
      final isBiometricAuth = biometricVM.isBiometricAuthenticated;

      final isBiometricPage = state.uri.toString() == '/biometric';

      if (!isBiometricAuth) {
        return isBiometricPage ? null : '/biometric';
      }

      if (isBiometricPage) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/biometric',
        builder: (context, state) => BiometricPage(viewModel: getIt()),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomePage(),
      ),
    ],
  );
}
