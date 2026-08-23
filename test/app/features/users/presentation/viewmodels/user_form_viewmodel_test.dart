import 'package:estoque_pro/app/core/services/authorization_service.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_entity.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_role.dart';
import 'package:estoque_pro/app/features/users/domain/repositories/users_repository.dart';
import 'package:estoque_pro/app/features/users/presentation/viewmodels/user_form_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockUsersRepository extends Mock implements UsersRepository {}

class MockAuthorizationService extends Mock implements AuthorizationService {}

void main() {
  late MockUsersRepository mockUsersRepository;
  late MockAuthorizationService mockAuthorizationService;
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
    viewModel = UserFormViewModel(mockUsersRepository, mockAuthorizationService);
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

    test('Owner can delete admins and sellers, but cannot delete himself', () {
      when(() => mockAuthorizationService.currentUser).thenReturn(ownerUser);

      expect(viewModel.canDelete(ownerUser), isFalse);
      expect(viewModel.canDelete(adminUser1), isTrue);
      expect(viewModel.canDelete(sellerUser), isTrue);
    });

    test('Admin can edit himself, other admins, and sellers, but NOT owner', () {
      when(() => mockAuthorizationService.currentUser).thenReturn(adminUser1);

      expect(viewModel.canEdit(adminUser1), isTrue);
      expect(viewModel.canEdit(adminUser2), isTrue);
      expect(viewModel.canEdit(sellerUser), isTrue);
      expect(viewModel.canEdit(ownerUser), isFalse);
    });

    test('Admin can delete other admins and sellers, but NOT owner or himself', () {
      when(() => mockAuthorizationService.currentUser).thenReturn(adminUser1);

      expect(viewModel.canDelete(sellerUser), isTrue);
      expect(viewModel.canDelete(adminUser2), isTrue);
      expect(viewModel.canDelete(adminUser1), isFalse);
      expect(viewModel.canDelete(ownerUser), isFalse);
    });

    test('updateUserCommand executes repository saveUser and succeeds', () async {
      when(() => mockUsersRepository.saveUser(any())).thenAnswer((_) async {});

      await viewModel.updateUserCommand.execute(sellerUser);

      expect(viewModel.updateUserCommand.isSuccess, isTrue);
      verify(() => mockUsersRepository.saveUser(sellerUser)).called(1);
    });

    test('deleteUserCommand executes repository deleteUser and succeeds', () async {
      when(() => mockUsersRepository.deleteUser('seller_1')).thenAnswer((_) async {});

      await viewModel.deleteUserCommand.execute('seller_1');

      expect(viewModel.deleteUserCommand.isSuccess, isTrue);
      verify(() => mockUsersRepository.deleteUser('seller_1')).called(1);
    });
  });
}
