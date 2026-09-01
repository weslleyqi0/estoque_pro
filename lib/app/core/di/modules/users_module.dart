import 'package:estoque_pro/app/core/di/modules/core_module.dart';
import 'package:estoque_pro/app/core/services/authorization_service.dart';
import 'package:estoque_pro/app/core/services/database_service.dart';
import 'package:estoque_pro/app/features/users/data/repositories/users_repository_impl.dart';
import 'package:estoque_pro/app/features/users/data/services/user_provisioning_service.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_entity.dart';
import 'package:estoque_pro/app/features/users/domain/repositories/users_repository.dart';
import 'package:estoque_pro/app/features/users/domain/usecases/create_user_use_case.dart';
import 'package:estoque_pro/app/features/users/domain/usecases/delete_user_use_case.dart';
import 'package:estoque_pro/app/features/users/domain/usecases/get_users_use_case.dart';
import 'package:estoque_pro/app/features/users/domain/usecases/save_user_use_case.dart';
import 'package:estoque_pro/app/features/users/presentation/viewmodels/user_form_viewmodel.dart';
import 'package:estoque_pro/app/features/users/presentation/viewmodels/users_viewmodel.dart';
import 'package:get_it/get_it.dart';

void setupUsersModule(GetIt getIt) {
  // Database Service
  registerDatabaseService<UserEntity>(getIt, 'users');

  // Services
  getIt.registerLazySingleton<UserProvisioningService>(
    () => UserProvisioningServiceImpl(),
  );

  // Repository
  getIt.registerLazySingleton<UsersRepository>(
    () => UsersRepositoryImpl(getIt<DatabaseService<UserEntity>>()),
  );

  // UseCases
  getIt.registerFactory<CreateUserUseCase>(
    () => CreateUserUseCase(
      getIt<UserProvisioningService>(),
      getIt<SaveUserUseCase>(),
    ),
  );
  getIt.registerFactory<GetUsersUseCase>(
    () => GetUsersUseCase(getIt<UsersRepository>()),
  );
  getIt.registerFactory<SaveUserUseCase>(
    () => SaveUserUseCase(getIt<UsersRepository>()),
  );
  getIt.registerFactory<DeleteUserUseCase>(
    () => DeleteUserUseCase(getIt<UsersRepository>()),
  );

  // ViewModels
  getIt.registerFactory<UsersViewModel>(
    () => UsersViewModel(
      getIt<GetUsersUseCase>(),
      getIt<SaveUserUseCase>(),
      getIt<DeleteUserUseCase>(),
      getIt<AuthorizationService>(),
    ),
  );
  getIt.registerFactory<UserFormViewModel>(
    () => UserFormViewModel(
      getIt<CreateUserUseCase>(),
      getIt<SaveUserUseCase>(),
      getIt<AuthorizationService>(),
    ),
  );
}
