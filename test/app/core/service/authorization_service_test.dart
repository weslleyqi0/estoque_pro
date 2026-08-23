import 'dart:async';

import 'package:estoque_pro/app/features/users/domain/entities/user_entity.dart';
import 'package:estoque_pro/app/core/services/authorization_service.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_permission.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_role.dart';
import 'package:estoque_pro/app/features/users/domain/repositories/users_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../fakes/fake_users.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

class MockUserRepository extends Mock implements UsersRepository {}

class FakeUserEntity extends Fake implements UserEntity {}

void main() {
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUserRepository mockUserRepository;
  late StreamController<User?> authStateController;
  late StreamController<UserEntity?> listenUserController;
  late AuthorizationService service;

  setUpAll(() {
    registerFallbackValue(FakeUserEntity());
  });

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockUserRepository = MockUserRepository();
    authStateController = StreamController<User?>.broadcast();
    listenUserController = StreamController<UserEntity?>.broadcast();

    when(() => mockFirebaseAuth.authStateChanges()).thenAnswer((_) => authStateController.stream);
    when(() => mockUserRepository.listenUser(any())).thenAnswer((_) => listenUserController.stream);

    service = AuthorizationService(mockFirebaseAuth, mockUserRepository);
    service.init();
  });

  tearDown(() {
    authStateController.close();
    listenUserController.close();
    service.dispose();
  });

  group('AuthorizationService Unit Tests', () {
    test('should owner role has all permissions and is active by default', () async {
      when(() => mockUserRepository.getUser('owner_uid')).thenAnswer((_) async => fakeOwnerUser);

      await service.loadUserProfile('owner_uid', 'owner@test.com');

      expect(service.currentUser, isNotNull);
      expect(service.currentUser!.role, UserRole.owner);
      expect(service.currentUser!.isActive, isTrue);

      for (final permission in UserPermission.values) {
        expect(service.hasPermission(permission), isTrue, reason: 'Owner should have permission $permission');
      }
    });

    test('should load user profile from repository when user exists', () async {
      when(() => mockUserRepository.getUser('seller_123')).thenAnswer((_) async => fakeSellerUser);

      await service.loadUserProfile('seller_123', 'seller@test.com');

      expect(service.currentUser, equals(fakeSellerUser));
      expect(service.hasUser, isTrue);
      expect(service.isLoading, isFalse);
      verify(() => mockUserRepository.getUser('seller_123')).called(1);
    });

    test('should provision user as owner when user does not exist and save succeeds', () async {
      when(() => mockUserRepository.getUser('new_owner_uid')).thenAnswer((_) async => null);
      when(() => mockUserRepository.saveUser(any())).thenAnswer((_) async => {});

      await service.loadUserProfile('new_owner_uid', 'dono@empresa.com');

      expect(service.currentUser, isNotNull);
      expect(service.currentUser!.uid, 'new_owner_uid');
      expect(service.currentUser!.name, 'Dono');
      expect(service.currentUser!.email, 'dono@empresa.com');
      expect(service.currentUser!.role, UserRole.owner);
      expect(service.currentUser!.isActive, isTrue);
      expect(service.currentUser!.permissions, UserPermission.values);

      verify(
        () => mockUserRepository.saveUser(
          any(
            that: isA<UserEntity>()
                .having((u) => u.role, 'role', UserRole.owner)
                .having((u) => u.isActive, 'isActive', isTrue),
          ),
        ),
      ).called(1);
    });

    test('should fallback to seller role when owner provision save fails', () async {
      when(() => mockUserRepository.getUser('new_seller_uid')).thenAnswer((_) async => null);
      when(() => mockUserRepository.saveUser(any())).thenThrow(Exception('Permission denied: DB already has users'));

      await service.loadUserProfile('new_seller_uid', 'vendedor@empresa.com');

      expect(service.currentUser, isNotNull);
      expect(service.currentUser!.uid, 'new_seller_uid');
      expect(service.currentUser!.name, 'vendedor');
      expect(service.currentUser!.email, 'vendedor@empresa.com');
      expect(service.currentUser!.role, UserRole.seller);
      expect(service.currentUser!.isActive, isTrue);
      expect(service.currentUser!.permissions, isEmpty);
    });

    test('should fallback to seller role when loadUserProfile throws an exception', () async {
      when(() => mockUserRepository.getUser('error_uid')).thenThrow(Exception('Network error'));

      await service.loadUserProfile('error_uid', 'user@empresa.com');

      expect(service.currentUser, isNotNull);
      expect(service.currentUser!.role, UserRole.seller);
      expect(service.currentUser!.isActive, isTrue);
      expect(service.isLoading, isFalse);
    });

    test('should clear current user and cancel subscription when authStateChanges emits null', () async {
      when(() => mockUserRepository.getUser('owner_uid')).thenAnswer((_) async => fakeOwnerUser);
      await service.loadUserProfile('owner_uid', 'owner@test.com');
      expect(service.hasUser, isTrue);

      authStateController.add(null);
      await pumpEventQueue();

      expect(service.currentUser, isNull);
      expect(service.hasUser, isFalse);
      expect(service.isLoading, isFalse);
    });

    test('should load profile when authStateChanges emits non-null user', () async {
      final mockUser = MockUser();
      when(() => mockUser.uid).thenReturn('uid_123');
      when(() => mockUser.email).thenReturn('user@test.com');
      when(() => mockUserRepository.getUser('uid_123')).thenAnswer((_) async => fakeSellerUser);

      authStateController.add(mockUser);
      await pumpEventQueue();

      expect(service.currentUser, equals(fakeSellerUser));
      verify(() => mockUserRepository.getUser('uid_123')).called(1);
    });

    test('should update current user in realtime when listenUser stream emits new user', () async {
      final mockUser = MockUser();
      when(() => mockUser.uid).thenReturn('seller_123');
      when(() => mockUser.email).thenReturn('seller@test.com');
      when(() => mockUserRepository.getUser('seller_123')).thenAnswer((_) async => fakeSellerUser);

      authStateController.add(mockUser);
      await pumpEventQueue();

      final updatedUser = UserEntity(
        uid: 'seller_123',
        name: 'Seller Atualizado',
        email: 'seller@test.com',
        role: UserRole.admin,
        isActive: true,
        permissions: UserPermission.values.toSet(),
      );

      listenUserController.add(updatedUser);
      await pumpEventQueue();

      expect(service.currentUser, equals(updatedUser));
      expect(service.hasRole(UserRole.admin), isTrue);
    });

    test('should return true for hasRole when role matches current user', () async {
      when(() => mockUserRepository.getUser('owner_123')).thenAnswer((_) async => fakeOwnerUser);

      await service.loadUserProfile('owner_123', 'owner@test.com');

      expect(service.hasRole(UserRole.owner), isTrue);
      expect(service.hasRole(UserRole.seller), isFalse);
      expect(service.hasRole(UserRole.admin), isFalse);
    });

    test('should return false for hasPermission when no user is logged in', () {
      expect(service.currentUser, isNull);
      expect(service.hasPermission(UserPermission.editProducts), isFalse);
    });
  });
}
