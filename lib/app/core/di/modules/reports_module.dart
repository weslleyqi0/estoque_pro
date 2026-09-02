import 'package:estoque_pro/app/features/customers/domain/usecases/get_customer_payments_use_case.dart';
import 'package:estoque_pro/app/features/customers/domain/usecases/get_customers_use_case.dart';
import 'package:estoque_pro/app/features/deliveries/domain/usecases/get_deliveries_use_case.dart';
import 'package:estoque_pro/app/features/products/domain/usecases/get_products_use_case.dart';
import 'package:estoque_pro/app/features/reports/domain/usecases/get_reports_use_case.dart';
import 'package:estoque_pro/app/features/reports/presentation/viewmodels/reports_viewmodel.dart';
import 'package:estoque_pro/app/features/sales/domain/usecases/get_sales_use_case.dart';
import 'package:estoque_pro/app/features/users/domain/usecases/get_users_use_case.dart';
import 'package:get_it/get_it.dart';

void setupReportsModule(GetIt getIt) {
  // UseCases
  getIt.registerLazySingleton<GetReportsUseCase>(
    () => const GetReportsUseCase(),
  );

  // ViewModels
  getIt.registerFactory<ReportsViewModel>(
    () => ReportsViewModel(
      getIt<GetReportsUseCase>(),
      getIt<GetProductsUseCase>(),
      getIt<GetSalesUseCase>(),
      getIt<GetDeliveriesUseCase>(),
      getIt<GetCustomersUseCase>(),
      getIt<GetCustomerPaymentsUseCase>(),
      getIt<GetUsersUseCase>(),
    ),
  );
}
