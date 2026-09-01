import 'package:estoque_pro/app/core/di/service_locator.dart';
import 'package:estoque_pro/app/core/router/app_routes.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:estoque_pro/app/features/deliveries/presentation/viewmodels/deliveries_viewmodel.dart';
import 'package:estoque_pro/app/features/home/presentation/pages/home_page.dart';
import 'package:estoque_pro/app/features/home/presentation/viewmodels/home_shortcuts_viewmodel.dart';
import 'package:estoque_pro/app/features/products/presentation/viewmodels/products_viewmodel.dart';
import 'package:estoque_pro/app/features/sales/presentation/viewmodels/sales_viewmodel.dart';
import 'package:go_router/go_router.dart';

List<GoRoute> homeRoutes() {
  return [
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => HomePage(
        authViewModel: getIt<AuthViewModel>(),
        salesViewModelFactory: () => getIt<SalesViewModel>(),
        productsViewModelFactory: () => getIt<ProductsViewModel>(),
        deliveriesViewModelFactory: () => getIt<DeliveriesViewModel>(),
        homeShortcutsViewModelFactory: () => getIt<HomeShortcutsViewModel>(),
      ),
    ),
  ];
}
