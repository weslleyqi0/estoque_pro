import 'package:estoque_pro/app/core/di/service_locator.dart';
import 'package:estoque_pro/app/core/router/app_routes.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/biometric_viewmodel.dart';
import 'package:estoque_pro/app/features/home/presentation/viewmodels/home_shortcuts_viewmodel.dart';
import 'package:estoque_pro/app/features/settings/presentation/pages/home_shortcuts_settings_page.dart';
import 'package:estoque_pro/app/features/settings/presentation/pages/settings_page.dart';
import 'package:estoque_pro/app/features/settings/presentation/viewmodels/theme_viewmodel.dart';
import 'package:go_router/go_router.dart';

List<GoRoute> settingsRoutes() {
  return [
    GoRoute(
      path: AppRoutes.settings,
      builder: (context, state) => SettingsPage(
        authViewModel: getIt<AuthViewModel>(),
        biometricViewModel: getIt<BiometricViewModel>(),
        themeViewModel: getIt<ThemeViewModel>(),
      ),
    ),
    GoRoute(
      path: AppRoutes.homeShortcutsSettings,
      builder: (context, state) => HomeShortcutsSettingsPage(
        viewModelFactory: () => getIt<HomeShortcutsViewModel>(),
        authViewModel: getIt<AuthViewModel>(),
      ),
    ),
  ];
}
