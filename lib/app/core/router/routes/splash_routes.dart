import 'package:estoque_pro/app/core/di/service_locator.dart';
import 'package:estoque_pro/app/core/router/app_routes.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:estoque_pro/app/features/splash/presentation/pages/splash_page.dart';
import 'package:estoque_pro/config/app_config.dart';
import 'package:go_router/go_router.dart';

List<GoRoute> splashRoutes() {
  return [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => SplashPage(
        authViewModel: getIt<AuthViewModel>(),
        appConfig: getIt<AppConfig>(),
      ),
    ),
  ];
}
