import 'package:estoque_pro/app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:estoque_pro/app/features/auth/data/service/auth_service.dart';
import 'package:estoque_pro/app/features/auth/data/service/biometric_service.dart';
import 'package:estoque_pro/app/features/auth/domain/repositories/auth_repository.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/biometric_viewmodel.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  // Services
  getIt.registerLazySingleton<AuthService>(() => AuthService());
  getIt.registerLazySingleton<BiometricService>(() => BiometricService());

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt<AuthService>(), getIt<BiometricService>()),
  );

  // ViewModels
  getIt.registerLazySingleton<AuthViewModel>(() => AuthViewModel());
  getIt.registerLazySingleton<BiometricViewModel>(() => BiometricViewModel());
}
