import 'package:estoque_pro/app/core/services/database_service.dart';
import 'package:estoque_pro/app/core/services/firebase_database_service.dart';
import 'package:estoque_pro/app/core/services/local_storage_service.dart';
import 'package:estoque_pro/app/features/home/presentation/viewmodels/home_shortcuts_viewmodel.dart';
import 'package:estoque_pro/app/features/settings/presentation/viewmodels/theme_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get_it/get_it.dart';

void registerDatabaseService<T>(GetIt getIt, String path) {
  getIt.registerLazySingleton<DatabaseService<T>>(
    () => FirebaseDatabaseService<T>(
      getIt<FirebaseDatabase>().ref(path),
    ),
  );
}

Future<void> setupCoreModule(GetIt getIt) async {
  // Firebase
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  getIt.registerLazySingleton<FirebaseDatabase>(() => FirebaseDatabase.instance);

  // Local Storage
  final localStorageService = LocalStorageService();
  await localStorageService.init();
  getIt.registerSingleton<LocalStorageService>(localStorageService);

  // Core ViewModels
  getIt.registerLazySingleton<ThemeViewModel>(
    () => ThemeViewModel(getIt<LocalStorageService>()),
  );
  getIt.registerLazySingleton<HomeShortcutsViewModel>(
    () => HomeShortcutsViewModel(getIt<LocalStorageService>()),
  );
}
