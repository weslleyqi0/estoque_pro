import 'dart:async';

import 'package:estoque_pro/app/core/services/database_service.dart';
import 'package:estoque_pro/app/features/users/data/repositories/users_repository_impl.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_entity.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_role.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDatabaseService extends Mock implements DatabaseService<UserEntity> {}

void main() {
  late MockDatabaseService mockDatabaseService;
  late UsersRepositoryImpl repository;

  setUp(() {
    mockDatabaseService = MockDatabaseService();
    repository = UsersRepositoryImpl(mockDatabaseService);
  });

  const testUser = UserEntity(
    uid: 'user-1',
    name: 'Admin User',
    email: 'admin@example.com',
    role: UserRole.admin,
    isActive: true,
    permissions: {},
  );

  group('UsersRepositoryImpl', () {
    test('getUser returns user when found', () async {
      when(() => mockDatabaseService.getChildOnce('user-1')).thenAnswer((_) async => {
            'name': 'Admin User',
            'email': 'admin@example.com',
            'role': 'admin',
            'isActive': true,
          });

      final result = await repository.getUser('user-1');

      expect(result.isSuccess, isTrue);
      expect(result.value?.name, equals('Admin User'));
      expect(result.value?.role, equals(UserRole.admin));
    });

    test('getUser returns null when user does not exist', () async {
      when(() => mockDatabaseService.getChildOnce('user-99')).thenAnswer((_) async => null);

      final result = await repository.getUser('user-99');

      expect(result.isSuccess, isTrue);
      expect(result.value, isNull);
    });

    test('listenUser emits mapped user', () async {
      final controller = StreamController<Map<String, dynamic>?>();
      when(() => mockDatabaseService.listenChild('user-1')).thenAnswer((_) => controller.stream);

      final stream = repository.listenUser('user-1');

      controller.add({
        'name': 'Admin User',
        'email': 'admin@example.com',
        'role': 'admin',
        'isActive': true,
      });

      final user = await stream.first;

      expect(user?.uid, equals('user-1'));
      expect(user?.name, equals('Admin User'));

      await controller.close();
    });

    test('saveUser updates multiple paths', () async {
      when(() => mockDatabaseService.updateMultiple(any())).thenAnswer((_) async {});

      final result = await repository.saveUser(testUser);

      expect(result.isSuccess, isTrue);
      verify(() => mockDatabaseService.updateMultiple(any())).called(1);
    });

    test('deleteUser clears user paths in updateMultiple', () async {
      when(() => mockDatabaseService.updateMultiple(any())).thenAnswer((_) async {});

      final result = await repository.deleteUser('user-1');

      expect(result.isSuccess, isTrue);
      verify(() => mockDatabaseService.updateMultiple({
            'users/user-1': null,
            'user_roles/user-1': null,
            'user_permissions/user-1': null,
          })).called(1);
    });

    test('getAllUsers returns list of users', () async {
      when(() => mockDatabaseService.getOnce()).thenAnswer((_) async => {
            'user-1': {
              'name': 'Admin User',
              'email': 'admin@example.com',
              'role': 'admin',
              'isActive': true,
            },
          });

      final result = await repository.getAllUsers();

      expect(result.isSuccess, isTrue);
      expect(result.value?.length, equals(1));
      expect(result.value?.first.uid, equals('user-1'));
    });

    test('listenAllUsers emits mapped user list', () async {
      final controller = StreamController<Map<String, dynamic>?>();
      when(() => mockDatabaseService.listen()).thenAnswer((_) => controller.stream);

      final stream = repository.listenAllUsers();

      controller.add({
        'user-1': {
          'name': 'Admin User',
          'email': 'admin@example.com',
          'role': 'admin',
          'isActive': true,
        },
      });

      final result = await stream.first;

      expect(result.isSuccess, isTrue);
      expect(result.value?.length, equals(1));
      expect(result.value?.first.name, equals('Admin User'));

      await controller.close();
    });
  });
}
