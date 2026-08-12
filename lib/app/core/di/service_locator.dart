import 'package:estoque_pro/app/core/services/firebase_database_service.dart';
import 'package:estoque_pro/app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:estoque_pro/app/features/auth/data/service/auth_service.dart';
import 'package:estoque_pro/app/features/auth/data/service/biometric_service.dart';
import 'package:estoque_pro/app/features/sales/data/repositories/sales_repository_impl.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/repositories/sales_repository.dart';
import 'package:estoque_pro/app/features/products/domain/usecases/count_products_use_case.dart';
import 'package:estoque_pro/app/features/sales/domain/usecases/save_sale_use_case.dart';
import 'package:estoque_pro/app/features/sales/presentation/viewmodels/cart_viewmodel.dart';
import 'package:estoque_pro/app/features/sales/presentation/viewmodels/sales_viewmodel.dart';
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
import 'package:estoque_pro/app/features/products/presentation/viewmodels/products_form_viewmodel.dart';
import 'package:estoque_pro/app/features/products/presentation/viewmodels/products_viewmodel.dart';
import 'package:estoque_pro/app/features/users/data/repositories/users_repository_impl.dart';
import 'package:estoque_pro/app/core/services/authorization_service.dart';
import 'package:estoque_pro/app/features/users/domain/repositories/users_repository.dart';
import 'package:estoque_pro/app/features/users/presentation/viewmodels/users_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void registerDatabaseService<T>(String path) {
  getIt.registerLazySingleton<FirebaseDatabaseService<T>>(
    () => FirebaseDatabaseService<T>(
      getIt<FirebaseDatabase>().ref(path),
    ),
  );
}

void setupServiceLocator() {
  // Firebase
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  getIt.registerLazySingleton<FirebaseDatabase>(() => FirebaseDatabase.instance);

  // Services / Data Sources
  registerDatabaseService<UserEntity>('users');
  registerDatabaseService<SupplierEntity>('suppliers');
  registerDatabaseService<CategoryEntity>('categories');
  registerDatabaseService<ProductEntity>('products');
  registerDatabaseService<SaleEntity>('sales');

  // Services
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
    () => AuthRepositoryImpl(getIt<AuthService>(), getIt<BiometricService>()),
  );

  getIt.registerLazySingleton<UsersRepository>(
    () => UsersRepositoryImpl(getIt<FirebaseDatabaseService<UserEntity>>()),
  );

  getIt.registerLazySingleton<SuppliersRepository>(
    () => SuppliersRepositoryImpl(
      getIt<FirebaseDatabaseService<SupplierEntity>>(),
    ),
  );

  getIt.registerLazySingleton<CategoriesRepository>(
    () => CategoriesRepositoryImpl(
      getIt<FirebaseDatabaseService<CategoryEntity>>(),
    ),
  );

  getIt.registerLazySingleton<ProductsRepository>(
    () => ProductsRepositoryImpl(
      getIt<FirebaseDatabaseService<ProductEntity>>(),
    ),
  );

  getIt.registerLazySingleton<SalesRepository>(
    () => SalesRepositoryImpl(
      getIt<FirebaseDatabaseService<SaleEntity>>(),
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

  // ViewModels
  getIt.registerLazySingleton<AuthViewModel>(
    () => AuthViewModel(
      getIt<AuthRepository>(),
      getIt<AuthorizationService>(),
    ),
  );
  getIt.registerLazySingleton<BiometricViewModel>(() => BiometricViewModel());
  getIt.registerFactory<UsersViewModel>(
    () => UsersViewModel(
      getIt<UsersRepository>(),
      getIt<AuthorizationService>(),
    ),
  );

  getIt.registerFactory<SuppliersViewModel>(
    () => SuppliersViewModel(getIt<SuppliersRepository>(), getIt<ProductsRepository>()),
  );
  getIt.registerFactory<SuppliersFormViewmodel>(
    () => SuppliersFormViewmodel(getIt<SuppliersRepository>()),
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

  getIt.registerLazySingleton<ProductsViewModel>(
    () => ProductsViewModel(getIt<ProductsRepository>()),
  );
  getIt.registerFactory<ProductsFormViewModel>(
    () => ProductsFormViewModel(
      getIt<ProductsRepository>(),
    ),
  );

  getIt.registerLazySingleton<SalesViewModel>(
    () => SalesViewModel(getIt<SalesRepository>()),
  );

  getIt.registerFactory<CartViewModel>(
    () => CartViewModel(getIt<SaveSaleUseCase>()),
  );
}
