import 'package:estoque_pro/app/core/di/service_locator.dart';
import 'package:estoque_pro/app/core/router/app_routes.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:estoque_pro/app/features/customers/presentation/viewmodels/customer_debts_viewmodel.dart';
import 'package:estoque_pro/app/features/customers/presentation/viewmodels/customers_viewmodel.dart';
import 'package:estoque_pro/app/features/deliveries/presentation/viewmodels/deliveries_viewmodel.dart';
import 'package:estoque_pro/app/features/products/presentation/viewmodels/products_viewmodel.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_entity.dart';
import 'package:estoque_pro/app/features/sales/presentation/pages/new_sale_page.dart';
import 'package:estoque_pro/app/features/sales/presentation/pages/sale_scanner_page.dart';
import 'package:estoque_pro/app/features/sales/presentation/pages/sales_page.dart';
import 'package:estoque_pro/app/features/sales/presentation/viewmodels/cart_viewmodel.dart';
import 'package:estoque_pro/app/features/sales/presentation/viewmodels/edit_sale_viewmodel.dart';
import 'package:estoque_pro/app/features/sales/presentation/viewmodels/sales_viewmodel.dart';
import 'package:go_router/go_router.dart';

List<GoRoute> salesRoutes() {
  return [
    GoRoute(
      path: AppRoutes.sales,
      builder: (context, state) {
        final initialTab = state.extra as SalesFilterTab?;
        return SalesPage(
          viewModelFactory: () => getIt<SalesViewModel>(),
          deliveriesViewModelFactory: () => getIt<DeliveriesViewModel>(),
          editSaleViewModelFactory: () => getIt<EditSaleViewModel>(),
          customersViewModelFactory: () => getIt<CustomersViewModel>(),
          debtsViewModelFactory: () => getIt<CustomerDebtsViewModel>(),
          authViewModel: getIt<AuthViewModel>(),
          initialTab: initialTab,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.newSale,
      builder: (context, state) {
        final sale = state.extra as SaleEntity?;
        return NewSalePage(
          productsViewModelFactory: () => getIt<ProductsViewModel>(),
          cartViewModelFactory: () => getIt<CartViewModel>(),
          customersViewModelFactory: () => getIt<CustomersViewModel>(),
          debtsViewModelFactory: () => getIt<CustomerDebtsViewModel>(),
          authViewModel: getIt<AuthViewModel>(),
          initialSale: sale,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.saleScanner,
      builder: (context, state) => const SaleScannerPage(),
    ),
  ];
}
