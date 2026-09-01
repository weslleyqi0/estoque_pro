import 'package:estoque_pro/app/core/di/service_locator.dart';
import 'package:estoque_pro/app/core/router/app_routes.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:estoque_pro/app/features/customers/domain/repositories/customers_repository.dart';
import 'package:estoque_pro/app/features/customers/presentation/viewmodels/customer_debts_viewmodel.dart';
import 'package:estoque_pro/app/features/customers/presentation/viewmodels/customers_viewmodel.dart';
import 'package:estoque_pro/app/features/deliveries/presentation/pages/deliveries_page.dart';
import 'package:estoque_pro/app/features/deliveries/presentation/viewmodels/deliveries_viewmodel.dart';
import 'package:estoque_pro/app/features/sales/domain/repositories/sales_repository.dart';
import 'package:go_router/go_router.dart';

List<GoRoute> deliveriesRoutes() {
  return [
    GoRoute(
      path: AppRoutes.deliveries,
      builder: (context, state) {
        final initialTab = state.extra as DeliveryFilterTab?;
        return DeliveriesPage(
          viewModelFactory: () => getIt<DeliveriesViewModel>(),
          customersViewModelFactory: () => getIt<CustomersViewModel>(),
          debtsViewModelFactory: () => getIt<CustomerDebtsViewModel>(),
          salesRepository: getIt<SalesRepository>(),
          customersRepository: getIt<CustomersRepository>(),
          authViewModel: getIt<AuthViewModel>(),
          initialTab: initialTab,
        );
      },
    ),
  ];
}
