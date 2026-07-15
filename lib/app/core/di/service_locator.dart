import 'package:estoque_pro/app/features/auth/data/service/biometric_service.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/biometric_viewmodel.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  // Services
  getIt.registerLazySingleton<BiometricService>(() => BiometricService());

  // ViewModels
  getIt.registerLazySingleton<BiometricViewModel>(() => BiometricViewModel());
}
