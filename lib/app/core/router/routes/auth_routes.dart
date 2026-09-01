import 'package:estoque_pro/app/core/di/service_locator.dart';
import 'package:estoque_pro/app/core/router/app_routes.dart';
import 'package:estoque_pro/app/features/auth/presentation/pages/biometric_page.dart';
import 'package:estoque_pro/app/features/auth/presentation/pages/inactive_page.dart';
import 'package:estoque_pro/app/features/auth/presentation/pages/login_page.dart';
import 'package:estoque_pro/app/features/auth/presentation/pages/unauthorized_page.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/biometric_viewmodel.dart';
import 'package:go_router/go_router.dart';

List<GoRoute> authRoutes() {
  return [
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => LoginPage(
        viewModelFactory: () => getIt<AuthViewModel>(),
      ),
    ),
    GoRoute(
      path: AppRoutes.biometric,
      builder: (context, state) => BiometricPage(
        viewModelFactory: () => getIt<BiometricViewModel>(),
      ),
    ),
    GoRoute(
      path: AppRoutes.inactive,
      builder: (context, state) => InactivePage(
        viewModelFactory: () => getIt<AuthViewModel>(),
      ),
    ),
    GoRoute(
      path: AppRoutes.unauthorized,
      builder: (context, state) => const UnauthorizedPage(),
    ),
  ];
}
