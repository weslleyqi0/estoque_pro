import 'package:estoque_pro/app/core/di/modules/core_module.dart';
import 'package:estoque_pro/app/core/services/database_service.dart';
import 'package:estoque_pro/app/features/customers/data/repositories/customer_payments_repository_impl.dart';
import 'package:estoque_pro/app/features/customers/data/repositories/customers_repository_impl.dart';
import 'package:estoque_pro/app/features/customers/domain/entities/customer_entity.dart';
import 'package:estoque_pro/app/features/customers/domain/entities/customer_payment_entity.dart';
import 'package:estoque_pro/app/features/customers/domain/repositories/customer_payments_repository.dart';
import 'package:estoque_pro/app/features/customers/domain/repositories/customers_repository.dart';
import 'package:estoque_pro/app/features/customers/domain/usecases/cancel_customer_payment_use_case.dart';
import 'package:estoque_pro/app/features/customers/domain/usecases/delete_customer_use_case.dart';
import 'package:estoque_pro/app/features/customers/domain/usecases/get_customer_payments_use_case.dart';
import 'package:estoque_pro/app/features/customers/domain/usecases/get_customers_use_case.dart';
import 'package:estoque_pro/app/features/customers/domain/usecases/register_customer_payment_use_case.dart';
import 'package:estoque_pro/app/features/customers/domain/usecases/save_customer_use_case.dart';
import 'package:estoque_pro/app/features/customers/domain/usecases/update_customer_use_case.dart';
import 'package:estoque_pro/app/features/customers/presentation/viewmodels/customer_debts_viewmodel.dart';
import 'package:estoque_pro/app/features/customers/presentation/viewmodels/customers_form_viewmodel.dart';
import 'package:estoque_pro/app/features/customers/presentation/viewmodels/customers_viewmodel.dart';
import 'package:estoque_pro/app/features/sales/domain/usecases/get_sales_use_case.dart';
import 'package:get_it/get_it.dart';

void setupCustomersModule(GetIt getIt) {
  // Database Services
  registerDatabaseService<CustomerEntity>(getIt, 'customers');
  registerDatabaseService<CustomerPaymentEntity>(getIt, 'customer_payments');

  // Repositories
  getIt.registerLazySingleton<CustomersRepository>(
    () => CustomersRepositoryImpl(
      getIt<DatabaseService<CustomerEntity>>(),
    ),
  );
  getIt.registerLazySingleton<CustomerPaymentsRepository>(
    () => CustomerPaymentsRepositoryImpl(
      getIt<DatabaseService<CustomerPaymentEntity>>(),
    ),
  );

  // UseCases
  getIt.registerFactory<GetCustomersUseCase>(
    () => GetCustomersUseCase(getIt<CustomersRepository>()),
  );
  getIt.registerFactory<SaveCustomerUseCase>(
    () => SaveCustomerUseCase(getIt<CustomersRepository>()),
  );
  getIt.registerFactory<UpdateCustomerUseCase>(
    () => UpdateCustomerUseCase(getIt<CustomersRepository>()),
  );
  getIt.registerFactory<DeleteCustomerUseCase>(
    () => DeleteCustomerUseCase(getIt<CustomersRepository>()),
  );
  getIt.registerFactory<GetCustomerPaymentsUseCase>(
    () => GetCustomerPaymentsUseCase(getIt<CustomerPaymentsRepository>()),
  );
  getIt.registerFactory<RegisterCustomerPaymentUseCase>(
    () => RegisterCustomerPaymentUseCase(getIt<CustomerPaymentsRepository>()),
  );
  getIt.registerFactory<CancelCustomerPaymentUseCase>(
    () => CancelCustomerPaymentUseCase(getIt<CustomerPaymentsRepository>()),
  );

  // ViewModels
  getIt.registerFactory<CustomersViewModel>(
    () => CustomersViewModel(getIt<GetCustomersUseCase>()),
  );
  getIt.registerFactory<CustomersFormViewModel>(
    () => CustomersFormViewModel(
      getIt<SaveCustomerUseCase>(),
      getIt<UpdateCustomerUseCase>(),
      getIt<DeleteCustomerUseCase>(),
    ),
  );
  getIt.registerFactory<CustomerDebtsViewModel>(
    () => CustomerDebtsViewModel(
      getIt<GetSalesUseCase>(),
      getIt<GetCustomerPaymentsUseCase>(),
      getIt<RegisterCustomerPaymentUseCase>(),
      getIt<CancelCustomerPaymentUseCase>(),
    ),
  );
}
