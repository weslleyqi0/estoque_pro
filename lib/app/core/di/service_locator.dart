import 'package:estoque_pro/app/core/services/firebase_database_service.dart';
import 'package:estoque_pro/app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:estoque_pro/app/features/auth/data/service/auth_service.dart';
import 'package:estoque_pro/app/features/auth/data/service/biometric_service.dart';
import 'package:estoque_pro/app/features/auth/domain/entities/user_entity.dart';
import 'package:estoque_pro/app/features/auth/domain/repositories/auth_repository.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/biometric_viewmodel.dart';
import 'package:estoque_pro/app/features/authorization/data/repositories/user_repository_impl.dart';
import 'package:estoque_pro/app/features/authorization/data/service/authorization_service.dart';
import 'package:estoque_pro/app/features/authorization/domain/repositories/user_repository.dart';
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

  // Services
  getIt.registerLazySingleton<AuthService>(() => AuthService());
  getIt.registerLazySingleton<BiometricService>(() => BiometricService());
  getIt.registerLazySingleton<AuthorizationService>(
    () => AuthorizationService(
      getIt<FirebaseAuth>(),
      getIt<UserRepository>(),
    ),
  );

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt<AuthService>(), getIt<BiometricService>()),
  );

  getIt.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(getIt<FirebaseDatabaseService<UserEntity>>()),
  );

  // ViewModels
  getIt.registerLazySingleton<AuthViewModel>(() => AuthViewModel());
  getIt.registerLazySingleton<BiometricViewModel>(() => BiometricViewModel());
}
