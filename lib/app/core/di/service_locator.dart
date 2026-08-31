import 'package:estoque_pro/app/core/services/firebase_database_service.dart';
import 'package:estoque_pro/app/core/services/local_storage_service.dart';
import 'package:estoque_pro/app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:estoque_pro/app/features/auth/data/service/auth_service.dart';
import 'package:estoque_pro/app/features/auth/data/service/biometric_service.dart';
import 'package:estoque_pro/app/features/deliveries/data/repositories/deliveries_repository_impl.dart';
import 'package:estoque_pro/app/features/deliveries/domain/entities/delivery_entity.dart';
import 'package:estoque_pro/app/features/deliveries/domain/repositories/deliveries_repository.dart';
import 'package:estoque_pro/app/features/deliveries/presentation/viewmodels/deliveries_viewmodel.dart';
import 'package:estoque_pro/app/features/sales/data/repositories/sales_repository_impl.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/repositories/sales_repository.dart';
import 'package:estoque_pro/app/features/products/domain/usecases/count_products_use_case.dart';
import 'package:estoque_pro/app/features/sales/domain/usecases/cancel_completed_sale_use_case.dart';
import 'package:estoque_pro/app/features/sales/domain/usecases/edit_sale_use_case.dart';
import 'package:estoque_pro/app/features/sales/domain/usecases/finalize_sale_use_case.dart';
import 'package:estoque_pro/app/features/sales/domain/usecases/save_draft_sale_use_case.dart';
import 'package:estoque_pro/app/features/sales/domain/usecases/save_sale_use_case.dart';
import 'package:estoque_pro/app/features/sales/presentation/viewmodels/cart_viewmodel.dart';
import 'package:estoque_pro/app/features/sales/presentation/viewmodels/edit_sale_viewmodel.dart';
import 'package:estoque_pro/app/features/sales/presentation/viewmodels/sales_viewmodel.dart';
import 'package:estoque_pro/app/features/customers/data/repositories/customer_payments_repository_impl.dart';
import 'package:estoque_pro/app/features/customers/data/repositories/customers_repository_impl.dart';
import 'package:estoque_pro/app/features/customers/domain/entities/customer_entity.dart';
import 'package:estoque_pro/app/features/customers/domain/entities/customer_payment_entity.dart';
import 'package:estoque_pro/app/features/customers/domain/repositories/customer_payments_repository.dart';
import 'package:estoque_pro/app/features/customers/domain/repositories/customers_repository.dart';
import 'package:estoque_pro/app/features/customers/presentation/viewmodels/customer_debts_viewmodel.dart';
import 'package:estoque_pro/app/features/customers/presentation/viewmodels/customers_form_viewmodel.dart';
import 'package:estoque_pro/app/features/customers/presentation/viewmodels/customers_viewmodel.dart';
import 'package:estoque_pro/app/features/suppliers/data/repositories/suppliers_repository_impl.dart';
import 'package:estoque_pro/app/features/suppliers/domain/entities/supplier_entity.dart';
import 'package:estoque_pro/app/features/suppliers/domain/repositories/suppliers_repository.dart';
import 'package:estoque_pro/app/features/suppliers/presentation/viewmodels/suppliers_form_viewmodel.dart';
import 'package:estoque_pro/app/features/suppliers/presentation/viewmodels/suppliers_viewmodel.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_entity.dart';
import 'package:estoque_pro/app/features/auth/domain/repositories/auth_repository.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/biometric_viewmodel.dart';
import 'package:estoque_pro/app/features/categories/data/repositories/categories_repository_impl.dart';
import 'package:estoque_pro/app/features/categories/domain/entities/category_entity.dart';
import 'package:estoque_pro/app/features/categories/domain/repositories/categories_repository.dart';
import 'package:estoque_pro/app/features/categories/presentation/viewmodels/categories_form_viewmodel.dart';
import 'package:estoque_pro/app/features/categories/presentation/viewmodels/categories_viewmodel.dart';
import 'package:estoque_pro/app/features/products/data/repositories/products_repository_impl.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_entity.dart';
import 'package:estoque_pro/app/features/products/domain/repositories/products_repository.dart';
import 'package:estoque_pro/app/features/products/presentation/viewmodels/archived_products_viewmodel.dart';
import 'package:estoque_pro/app/features/products/presentation/viewmodels/product_history_viewmodel.dart';
import 'package:estoque_pro/app/features/products/presentation/viewmodels/products_form_viewmodel.dart';
import 'package:estoque_pro/app/features/products/presentation/viewmodels/products_viewmodel.dart';
import 'package:estoque_pro/app/features/users/data/repositories/users_repository_impl.dart';
import 'package:estoque_pro/app/core/services/authorization_service.dart';
import 'package:estoque_pro/app/features/users/domain/repositories/users_repository.dart';
import 'package:estoque_pro/app/features/users/presentation/viewmodels/user_form_viewmodel.dart';
import 'package:estoque_pro/app/features/users/presentation/viewmodels/users_viewmodel.dart';
import 'package:estoque_pro/app/features/home/presentation/viewmodels/home_shortcuts_viewmodel.dart';
import 'package:estoque_pro/app/features/settings/presentation/viewmodels/theme_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get_it/get_it.dart';
import '../services/database_service.dart';

final getIt = GetIt.instance;

void registerDatabaseService<T>(String path) {
  getIt.registerLazySingleton<DatabaseService<T>>(
    () => FirebaseDatabaseService<T>(
      getIt<FirebaseDatabase>().ref(path),
    ),
  );
}

Future<void> setupServiceLocator() async {
  // Firebase
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  getIt.registerLazySingleton<FirebaseDatabase>(() => FirebaseDatabase.instance);

  // Services / Data Sources
  registerDatabaseService<UserEntity>('users');
  registerDatabaseService<SupplierEntity>('suppliers');
  registerDatabaseService<CustomerEntity>('customers');
  registerDatabaseService<CustomerPaymentEntity>('customer_payments');
  registerDatabaseService<CategoryEntity>('categories');
  registerDatabaseService<ProductEntity>('products');
  registerDatabaseService<SaleEntity>('sales');
  registerDatabaseService<DeliveryEntity>('deliveries');

  // Services
  final localStorageService = LocalStorageService();
  await localStorageService.init();
  getIt.registerSingleton<LocalStorageService>(localStorageService);

  getIt.registerLazySingleton<AuthService>(() => AuthService());
  getIt.registerLazySingleton<BiometricService>(() => BiometricService());
  getIt.registerLazySingleton<AuthorizationService>(
    () {
      final service = AuthorizationService(
        getIt<FirebaseAuth>(),
        getIt<UsersRepository>(),
      );
      service.init();
      return service;
    },
  );

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      getIt<AuthService>(),
      getIt<BiometricService>(),
      getIt<LocalStorageService>(),
    ),
  );

  getIt.registerLazySingleton<UsersRepository>(
    () => UsersRepositoryImpl(getIt<DatabaseService<UserEntity>>()),
  );

  getIt.registerLazySingleton<SuppliersRepository>(
    () => SuppliersRepositoryImpl(
      getIt<DatabaseService<SupplierEntity>>(),
    ),
  );

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

  getIt.registerLazySingleton<CategoriesRepository>(
    () => CategoriesRepositoryImpl(
      getIt<DatabaseService<CategoryEntity>>(),
    ),
  );

  getIt.registerLazySingleton<ProductsRepository>(
    () => ProductsRepositoryImpl(
      getIt<DatabaseService<ProductEntity>>(),
    ),
  );

  getIt.registerLazySingleton<SalesRepository>(
    () => SalesRepositoryImpl(
      getIt<DatabaseService<SaleEntity>>(),
    ),
  );

  getIt.registerLazySingleton<DeliveriesRepository>(
    () => DeliveriesRepositoryImpl(
      getIt<DatabaseService<DeliveryEntity>>(),
    ),
  );

  // UseCases
  getIt.registerFactory<CountProductsUseCase>(
    () => CountProductsUseCase(getIt<ProductsRepository>()),
  );

  getIt.registerFactory<SaveSaleUseCase>(
    () => SaveSaleUseCase(
      getIt<SalesRepository>(),
      getIt<ProductsRepository>(),
    ),
  );

  getIt.registerFactory<FinalizeSaleUseCase>(
    () => FinalizeSaleUseCase(
      getIt<SaveSaleUseCase>(),
      getIt<DeliveriesRepository>(),
    ),
  );

  getIt.registerFactory<SaveDraftSaleUseCase>(
    () => SaveDraftSaleUseCase(getIt<SaveSaleUseCase>()),
  );

  getIt.registerFactory<EditSaleUseCase>(
    () => EditSaleUseCase(
      getIt<SalesRepository>(),
      getIt<ProductsRepository>(),
    ),
  );

  getIt.registerFactory<CancelCompletedSaleUseCase>(
    () => CancelCompletedSaleUseCase(getIt<SalesRepository>()),
  );

  // ViewModels
  getIt.registerLazySingleton<ThemeViewModel>(
    () => ThemeViewModel(getIt<LocalStorageService>()),
  );
  getIt.registerLazySingleton<HomeShortcutsViewModel>(
    () => HomeShortcutsViewModel(getIt<LocalStorageService>()),
  );
  getIt.registerFactory<CustomerDebtsViewModel>(
    () => CustomerDebtsViewModel(
      getIt<SalesRepository>(),
      getIt<CustomerPaymentsRepository>(),
    ),
  );
  getIt.registerLazySingleton<AuthViewModel>(
    () => AuthViewModel(
      getIt<AuthRepository>(),
      getIt<AuthorizationService>(),
    ),
  );
  getIt.registerLazySingleton<BiometricViewModel>(
    () => BiometricViewModel(getIt<AuthRepository>()),
  );
  getIt.registerFactory<UsersViewModel>(
    () => UsersViewModel(
      getIt<UsersRepository>(),
      getIt<AuthorizationService>(),
    ),
  );
  getIt.registerFactory<UserFormViewModel>(
    () => UserFormViewModel(
      getIt<UsersRepository>(),
      getIt<AuthorizationService>(),
    ),
  );

  getIt.registerFactory<SuppliersViewModel>(
    () => SuppliersViewModel(
      getIt<SuppliersRepository>(),
      getIt<CountProductsUseCase>(),
    ),
  );
  getIt.registerFactory<SuppliersFormViewmodel>(
    () => SuppliersFormViewmodel(getIt<SuppliersRepository>()),
  );

  getIt.registerFactory<CustomersViewModel>(
    () => CustomersViewModel(getIt<CustomersRepository>()),
  );
  getIt.registerFactory<CustomersFormViewModel>(
    () => CustomersFormViewModel(getIt<CustomersRepository>()),
  );

  getIt.registerFactory<CategoriesViewModel>(
    () => CategoriesViewModel(
      getIt<CategoriesRepository>(),
      getIt<CountProductsUseCase>(),
    ),
  );
  getIt.registerFactory<CategoriesFormViewmodel>(
    () => CategoriesFormViewmodel(getIt<CategoriesRepository>()),
  );

  getIt.registerFactory<ProductsViewModel>(
    () => ProductsViewModel(getIt<ProductsRepository>()),
  );
  getIt.registerFactory<ArchivedProductsViewModel>(
    () => ArchivedProductsViewModel(getIt<ProductsRepository>()),
  );
  getIt.registerFactory<ProductHistoryViewModel>(
    () => ProductHistoryViewModel(getIt<ProductsRepository>()),
  );
  getIt.registerFactory<ProductsFormViewModel>(
    () => ProductsFormViewModel(getIt<ProductsRepository>()),
  );

  getIt.registerFactory<SalesViewModel>(
    () => SalesViewModel(
      getIt<SalesRepository>(),
      getIt<DeliveriesRepository>(),
    ),
  );

  getIt.registerFactory<DeliveriesViewModel>(
    () => DeliveriesViewModel(getIt<DeliveriesRepository>()),
  );

  getIt.registerFactory<CartViewModel>(
    () => CartViewModel(
      getIt<FinalizeSaleUseCase>(),
      getIt<SaveDraftSaleUseCase>(),
    ),
  );

  getIt.registerFactory<EditSaleViewModel>(
    () => EditSaleViewModel(
      getIt<EditSaleUseCase>(),
      getIt<CancelCompletedSaleUseCase>(),
      getIt<ProductsRepository>(),
    ),
  );
}

