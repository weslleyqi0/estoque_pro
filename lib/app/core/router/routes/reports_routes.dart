import 'package:estoque_pro/app/core/di/service_locator.dart';
import 'package:estoque_pro/app/core/router/app_routes.dart';
import 'package:estoque_pro/app/features/reports/presentation/pages/reports_page.dart';
import 'package:estoque_pro/app/features/reports/presentation/viewmodels/reports_viewmodel.dart';
import 'package:go_router/go_router.dart';

List<GoRoute> reportsRoutes() {
  return [
    GoRoute(
      path: AppRoutes.reports,
      builder: (context, state) {
        return ReportsPage(
          viewModelFactory: () => getIt<ReportsViewModel>(),
        );
      },
    ),
  ];
}
