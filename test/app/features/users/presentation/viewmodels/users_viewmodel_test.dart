import 'dart:async';

import 'package:estoque_pro/app/core/services/authorization_service.dart';
import 'package:estoque_pro/app/core/utils/result.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_entity.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_permission.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_role.dart';
import 'package:estoque_pro/app/features/users/domain/repositories/users_repository.dart';
import 'package:estoque_pro/app/features/users/domain/usecases/delete_user_use_case.dart';
import 'package:estoque_pro/app/features/users/domain/usecases/get_users_use_case.dart';
import 'package:estoque_pro/app/features/users/domain/usecases/save_user_use_case.dart';
import 'package:estoque_pro/app/features/users/presentation/viewmodels/users_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockUsersRepository extends Mock implements UsersRepository {}
class MockAuthorizationService extends Mock implements AuthorizationService {}

void main() {
  late MockUsersRepository mockUsersRepo;
  late MockAuthorizationService mockAuthService;
  late GetUsersUseCase getUsersUseCase;
  late SaveUserUseCase saveUserUseCase;
  late DeleteUserUseCase deleteUserUseCase;
  late StreamController<Result<List<UserEntity>>> usersController;
  late UsersViewModel viewModel;

  const ownerUser = UserEntity(
    uid: 'u_owner',
    name: 'Dono da Loja',
    email: 'owner@test.com',
    role: UserRole.owner,
    isActive: true,
    permissions: {},
  );

  const adminUser = UserEntity(
    uid: 'u_admin',
    name: 'Gerente Admin',
    email: 'admin@test.com',
    role: UserRole.admin,
    isActive: true,
    permissions: {},
  );

  const sellerUser = UserEntity(
    uid: 'u_seller',
    name: 'Vendedor 1',
    email: 'seller@test.com',
    role: UserRole.seller,
    isActive: true,
    permissions: {},
  );

  setUpAll(() {
    registerFallbackValue(sellerUser);
  });

  setUp(() {
    mockUsersRepo = MockUsersRepository();
    mockAuthService = MockAuthorizationService();
    getUsersUseCase = GetUsersUseCase(mockUsersRepo);
    saveUserUseCase = SaveUserUseCase(mockUsersRepo);
    deleteUserUseCase = DeleteUserUseCase(mockUsersRepo);

    usersController = StreamController<Result<List<UserEntity>>>.broadcast();
    when(() => mockUsersRepo.listenAllUsers()).thenAnswer((_) => usersController.stream);
    when(() => mockAuthService.currentUser).thenReturn(ownerUser);

    viewModel = UsersViewModel(
      getUsersUseCase,
      saveUserUseCase,
      deleteUserUseCase,
      mockAuthService,
    );
  });

  tearDown(() {
    usersController.close();
    viewModel.dispose();
  });

  test('listenAllUsers updates state and sorts owner first', () async {
    viewModel.listenAllUsers();
    expect(viewModel.isLoading, isTrue);

    usersController.add(const Result.success([sellerUser, adminUser, ownerUser]));
    await pumpEventQueue();

    expect(viewModel.state, UsersLoadState.success);
    expect(viewModel.users.length, 3);
    expect(viewModel.users.first.uid, 'u_owner');
  });

  test('toggleUserPermission toggles permission and executes update command', () async {
    when(() => mockUsersRepo.saveUser(any())).thenAnswer((_) async {});

    viewModel.toggleUserPermission(sellerUser, UserPermission.editSales);
    await pumpEventQueue();

    expect(viewModel.updateUserProfileCommand.isSuccess, isTrue);
    verify(() => mockUsersRepo.saveUser(any())).called(1);
  });

  test('deleteUserCommand executes delete on repository', () async {
    when(() => mockUsersRepo.deleteUser(any())).thenAnswer((_) async {});

    await viewModel.deleteUserCommand.execute('u_seller');

    expect(viewModel.deleteUserCommand.isSuccess, isTrue);
    verify(() => mockUsersRepo.deleteUser('u_seller')).called(1);
  });
}
