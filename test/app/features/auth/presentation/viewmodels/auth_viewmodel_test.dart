import 'package:estoque_pro/app/core/services/authorization_service.dart';
import 'package:estoque_pro/app/core/utils/result.dart';
import 'package:estoque_pro/app/features/auth/domain/entities/auth_user_entity.dart';
import 'package:estoque_pro/app/features/auth/domain/repositories/auth_repository.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_entity.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_role.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockAuthorizationService extends Mock implements AuthorizationService {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockAuthorizationService mockAuthorizationService;
  late AuthViewModel viewModel;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockAuthorizationService = MockAuthorizationService();

    when(() => mockAuthRepository.addListener(any())).thenReturn(null);
    when(() => mockAuthRepository.removeListener(any())).thenReturn(null);
    when(() => mockAuthorizationService.addListener(any())).thenReturn(null);
    when(() => mockAuthorizationService.removeListener(any())).thenReturn(null);

    when(() => mockAuthRepository.currentUser).thenReturn(
      const AuthUserEntity(uid: 'uid-1', email: 'test@example.com'),
    );
    when(() => mockAuthRepository.isBiometricAuthenticated).thenReturn(true);
    when(() => mockAuthorizationService.currentUser).thenReturn(
      const UserEntity(
        uid: 'uid-1',
        name: 'Admin',
        email: 'test@example.com',
        role: UserRole.admin,
        permissions: {},
        isActive: true,
      ),
    );
    when(() => mockAuthorizationService.isAuthenticated).thenReturn(true);

    viewModel = AuthViewModel(mockAuthRepository, mockAuthorizationService);
  });

  tearDown(() {
    viewModel.dispose();
  });

  group('AuthViewModel', () {
    test('exposes user state correctly from repository and authorization service', () {
      expect(viewModel.authenticatedUser?.uid, equals('uid-1'));
      expect(viewModel.isBiometricAuthenticated, isTrue);
      expect(viewModel.currentUser?.name, equals('Admin'));
      expect(viewModel.isAuthenticated, isTrue);
    });

    test('loginCommand executes signIn and succeeds', () async {
      when(() => mockAuthRepository.signIn(any(), any())).thenAnswer((_) async => const Result.success(null));

      await viewModel.loginCommand.execute((email: 'test@example.com', password: 'password'));

      expect(viewModel.loginCommand.isSuccess, isTrue);
      verify(() => mockAuthRepository.signIn('test@example.com', 'password')).called(1);
    });

    test('loginCommand handles failure', () async {
      when(
        () => mockAuthRepository.signIn(any(), any()),
      ).thenAnswer((_) async => Result.failure(BusinessRuleFailure(message: 'Credenciais inválidas')));

      await viewModel.loginCommand.execute((email: 'test@example.com', password: 'wrong'));

      expect(viewModel.loginCommand.isFailure, isTrue);
    });

    test('logoutCommand executes signOut and succeeds', () async {
      when(() => mockAuthRepository.signOut()).thenAnswer((_) async => const Result.success(null));

      await viewModel.logoutCommand.execute();

      expect(viewModel.logoutCommand.isSuccess, isTrue);
      verify(() => mockAuthRepository.signOut()).called(1);
    });

    test('setBiometricAuthenticated forwards to repository', () {
      when(() => mockAuthRepository.setBiometricAuthenticated(any())).thenReturn(null);

      viewModel.setBiometricAuthenticated(false);

      verify(() => mockAuthRepository.setBiometricAuthenticated(false)).called(1);
    });
  });
}
