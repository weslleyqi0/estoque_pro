import 'package:estoque_pro/app/core/services/firebase_database_service.dart';
import 'package:estoque_pro/app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:estoque_pro/app/features/auth/data/service/auth_service.dart';
import 'package:estoque_pro/app/features/auth/data/service/biometric_service.dart';
import 'package:estoque_pro/app/features/suppliers/data/repositories/suppliers_repository_impl.dart';
import 'package:estoque_pro/app/features/suppliers/domain/entities/supplier_entity.dart';
import 'package:estoque_pro/app/features/suppliers/domain/repositories/suppliers_repository.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_entity.dart';
import 'package:estoque_pro/app/features/auth/domain/repositories/auth_repository.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/biometric_viewmodel.dart';
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

  // Services
  getIt.registerLazySingleton<AuthService>(() => AuthService());
  getIt.registerLazySingleton<BiometricService>(() => BiometricService());
  getIt.registerLazySingleton<AuthorizationService>(
    () => AuthorizationService(
      getIt<FirebaseAuth>(),
      getIt<UsersRepository>(),
    ),
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
}
