import 'package:estoque_pro/app/core/services/authorization_service.dart';
import 'package:estoque_pro/app/core/services/local_storage_service.dart';
import 'package:estoque_pro/app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:estoque_pro/app/features/auth/data/service/auth_service.dart';
import 'package:estoque_pro/app/features/auth/data/service/biometric_service.dart';
import 'package:estoque_pro/app/features/auth/domain/repositories/auth_repository.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/biometric_viewmodel.dart';
import 'package:estoque_pro/app/features/users/domain/repositories/users_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

void setupAuthModule(GetIt getIt) {
  // Services
  getIt.registerLazySingleton<AuthService>(
    () => AuthServiceImpl(getIt<FirebaseAuth>()),
  );
  getIt.registerLazySingleton<BiometricService>(
    () => BiometricService(),
  );
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

  // ViewModels
  getIt.registerLazySingleton<AuthViewModel>(
    () => AuthViewModel(
      getIt<AuthRepository>(),
      getIt<AuthorizationService>(),
    ),
  );
  getIt.registerLazySingleton<BiometricViewModel>(
    () => BiometricViewModel(getIt<AuthRepository>()),
  );
}
