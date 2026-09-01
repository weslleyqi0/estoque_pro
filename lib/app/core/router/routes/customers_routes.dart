import 'package:estoque_pro/app/core/di/service_locator.dart';
import 'package:estoque_pro/app/core/router/app_routes.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:estoque_pro/app/features/customers/domain/entities/customer_entity.dart';
import 'package:estoque_pro/app/features/customers/presentation/pages/customer_form_page.dart';
import 'package:estoque_pro/app/features/customers/presentation/pages/customers_page.dart';
import 'package:estoque_pro/app/features/customers/presentation/viewmodels/customer_debts_viewmodel.dart';
import 'package:estoque_pro/app/features/customers/presentation/viewmodels/customers_form_viewmodel.dart';
import 'package:estoque_pro/app/features/customers/presentation/viewmodels/customers_viewmodel.dart';
import 'package:go_router/go_router.dart';

List<GoRoute> customersRoutes() {
  return [
    GoRoute(
      path: AppRoutes.customers,
      builder: (context, state) => CustomersPage(
        viewModelFactory: () => getIt<CustomersViewModel>(),
        debtsViewModelFactory: () => getIt<CustomerDebtsViewModel>(),
        authViewModel: getIt<AuthViewModel>(),
      ),
    ),
    GoRoute(
      path: AppRoutes.customerForm,
      builder: (context, state) {
        final customer = state.extra as CustomerEntity?;
        return CustomerFormPage(
          viewModelFactory: () => getIt<CustomersFormViewModel>(),
          customer: customer,
        );
      },
    ),
  ];
}
