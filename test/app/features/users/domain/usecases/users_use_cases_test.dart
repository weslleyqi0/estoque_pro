import 'package:estoque_pro/app/core/utils/result.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_entity.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_role.dart';
import 'package:estoque_pro/app/features/users/domain/repositories/users_repository.dart';
import 'package:estoque_pro/app/features/users/domain/usecases/delete_user_use_case.dart';
import 'package:estoque_pro/app/features/users/domain/usecases/get_users_use_case.dart';
import 'package:estoque_pro/app/features/users/domain/usecases/save_user_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockUsersRepository extends Mock implements UsersRepository {}

void main() {
  late MockUsersRepository mockRepository;

  const testUser = UserEntity(
    uid: 'u1',
    name: 'João Silva',
    email: 'joao@test.com',
    role: UserRole.admin,
    isActive: true,
    permissions: {},
  );

  setUpAll(() {
    registerFallbackValue(testUser);
  });

  setUp(() {
    mockRepository = MockUsersRepository();
  });

  group('GetUsersUseCase', () {
    test('listenAllUsers delegates to repository', () {
      when(() => mockRepository.listenAllUsers()).thenAnswer(
        (_) => Stream.value(const Result.success([testUser])),
      );

      final useCase = GetUsersUseCase(mockRepository);
      expect(useCase.listenAllUsers(), emits(isA<Success<List<UserEntity>>>()));
    });

    test('getAllUsers delegates to repository', () async {
      when(() => mockRepository.getAllUsers()).thenAnswer((_) async => const Result.success([testUser]));

      final useCase = GetUsersUseCase(mockRepository);
      final result = await useCase.getAllUsers();
      expect(result.value, equals([testUser]));
    });

    test('getUser delegates to repository', () async {
      when(() => mockRepository.getUser('u1')).thenAnswer((_) async => const Result.success(testUser));

      final useCase = GetUsersUseCase(mockRepository);
      final result = await useCase.getUser('u1');
      expect(result.value, equals(testUser));
    });

    test('listenUser delegates to repository', () {
      when(() => mockRepository.listenUser('u1')).thenAnswer((_) => Stream.value(testUser));

      final useCase = GetUsersUseCase(mockRepository);
      expect(useCase.listenUser('u1'), emits(testUser));
    });
  });

  group('SaveUserUseCase', () {
    test('returns BusinessRuleFailure if uid is empty', () async {
      final useCase = SaveUserUseCase(mockRepository);
      final result = await useCase.call(testUser.copyWith(uid: ''));

      expect(result.isFailure, isTrue);
      expect(result.error, isA<BusinessRuleFailure>());
    });

    test('returns BusinessRuleFailure if name is empty', () async {
      final useCase = SaveUserUseCase(mockRepository);
      final result = await useCase.call(testUser.copyWith(name: '  '));

      expect(result.isFailure, isTrue);
      expect(result.error, isA<BusinessRuleFailure>());
    });

    test('returns BusinessRuleFailure if email is empty', () async {
      final useCase = SaveUserUseCase(mockRepository);
      final result = await useCase.call(testUser.copyWith(email: ''));

      expect(result.isFailure, isTrue);
      expect(result.error, isA<BusinessRuleFailure>());
    });

    test('saves and returns success when valid', () async {
      when(() => mockRepository.saveUser(any())).thenAnswer((_) async => const Result.success(null));

      final useCase = SaveUserUseCase(mockRepository);
      final result = await useCase.call(testUser);

      expect(result.isSuccess, isTrue);
      expect(result.value, isTrue);
    });
  });

  group('DeleteUserUseCase', () {
    test('returns BusinessRuleFailure if uid is empty', () async {
      final useCase = DeleteUserUseCase(mockRepository);
      final result = await useCase.call('');

      expect(result.isFailure, isTrue);
      expect(result.error, isA<BusinessRuleFailure>());
    });

    test('deletes and returns success when valid', () async {
      when(() => mockRepository.deleteUser('u1')).thenAnswer((_) async => const Result.success(null));

      final useCase = DeleteUserUseCase(mockRepository);
      final result = await useCase.call('u1');

      expect(result.isSuccess, isTrue);
      expect(result.value, isTrue);
    });
  });
}
