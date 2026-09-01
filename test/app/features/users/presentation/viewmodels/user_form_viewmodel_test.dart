import 'package:estoque_pro/app/core/services/authorization_service.dart';
import 'package:estoque_pro/app/core/utils/result.dart';
import 'package:estoque_pro/app/features/users/data/services/user_provisioning_service.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_entity.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_role.dart';
import 'package:estoque_pro/app/features/users/domain/repositories/users_repository.dart';
import 'package:estoque_pro/app/features/users/domain/usecases/create_user_use_case.dart';
import 'package:estoque_pro/app/features/users/domain/usecases/save_user_use_case.dart';
import 'package:estoque_pro/app/features/users/presentation/viewmodels/user_form_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockUsersRepository extends Mock implements UsersRepository {}

class MockAuthorizationService extends Mock implements AuthorizationService {}

class MockUserProvisioningService extends Mock implements UserProvisioningService {}

void main() {
  late MockUsersRepository mockUsersRepository;
  late MockAuthorizationService mockAuthorizationService;
  late MockUserProvisioningService mockUserProvisioningService;
  late CreateUserUseCase createUserUseCase;
  late UserFormViewModel viewModel;

  setUpAll(() {
    registerFallbackValue(
      const UserEntity(
        uid: 'fallback',
        name: 'Fallback',
        email: 'fallback@test.com',
        role: UserRole.seller,
        isActive: true,
        permissions: {},
      ),
    );
  });

  setUp(() {
    mockUsersRepository = MockUsersRepository();
    mockAuthorizationService = MockAuthorizationService();
    mockUserProvisioningService = MockUserProvisioningService();
    final saveUserUseCase = SaveUserUseCase(mockUsersRepository);
    createUserUseCase = CreateUserUseCase(mockUserProvisioningService, saveUserUseCase);
    viewModel = UserFormViewModel(
      createUserUseCase,
      saveUserUseCase,
      mockAuthorizationService,
    );
  });

  group('UserFormViewModel RBAC Permission Rules Tests', () {
    const ownerUser = UserEntity(
      uid: 'owner_1',
      name: 'Owner',
      email: 'owner@test.com',
      role: UserRole.owner,
      isActive: true,
      permissions: {},
    );

    const adminUser1 = UserEntity(
      uid: 'admin_1',
      name: 'Admin 1',
      email: 'admin1@test.com',
      role: UserRole.admin,
      isActive: true,
      permissions: {},
    );

    const adminUser2 = UserEntity(
      uid: 'admin_2',
      name: 'Admin 2',
      email: 'admin2@test.com',
      role: UserRole.admin,
      isActive: true,
      permissions: {},
    );

    const sellerUser = UserEntity(
      uid: 'seller_1',
      name: 'Seller 1',
      email: 'seller1@test.com',
      role: UserRole.seller,
      isActive: true,
      permissions: {},
    );

    test('Owner can edit himself and other users (admins and sellers)', () {
      when(() => mockAuthorizationService.currentUser).thenReturn(ownerUser);

      expect(viewModel.canEdit(ownerUser), isTrue);
      expect(viewModel.canEdit(adminUser1), isTrue);
      expect(viewModel.canEdit(sellerUser), isTrue);
    });

    test('Admin can edit himself, other admins, and sellers, but NOT owner', () {
      when(() => mockAuthorizationService.currentUser).thenReturn(adminUser1);

      expect(viewModel.canEdit(adminUser1), isTrue);
      expect(viewModel.canEdit(adminUser2), isTrue);
      expect(viewModel.canEdit(sellerUser), isTrue);
      expect(viewModel.canEdit(ownerUser), isFalse);
    });

    test('updateUserCommand executes repository saveUser and succeeds', () async {
      when(() => mockUsersRepository.saveUser(any())).thenAnswer((_) async => const Result.success(null));

      await viewModel.updateUserCommand.execute(sellerUser);

      expect(viewModel.updateUserCommand.isSuccess, isTrue);
      verify(() => mockUsersRepository.saveUser(sellerUser)).called(1);
    });

    test('createUserCommand provisions user and saves profile', () async {
      when(() => mockUserProvisioningService.createUserWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => const Result.success('new_uid_123'));
      when(() => mockUsersRepository.saveUser(any())).thenAnswer((_) async => const Result.success(null));

      await viewModel.createUserCommand.execute((
        name: 'New Seller',
        email: 'newseller@test.com',
        password: 'password123',
        role: UserRole.seller,
      ));

      expect(viewModel.createUserCommand.isSuccess, isTrue);
      verify(() => mockUserProvisioningService.createUserWithEmailAndPassword(
            email: 'newseller@test.com',
            password: 'password123',
          )).called(1);
      verify(() => mockUsersRepository.saveUser(any())).called(1);
    });
  });
}
