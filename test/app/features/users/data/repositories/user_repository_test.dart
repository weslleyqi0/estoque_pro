import 'package:estoque_pro/app/core/services/firebase_database_service.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_entity.dart';
import 'package:estoque_pro/app/features/users/data/repositories/users_repository_impl.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_permission.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_role.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseDatabase extends Mock implements FirebaseDatabase {}

class MockDatabaseReference extends Mock implements DatabaseReference {}

class MockDataSnapshot extends Mock implements DataSnapshot {}

void main() {
  late MockFirebaseDatabase mockDb;
  late MockDatabaseReference mockRef;
  late MockDatabaseReference mockUsersRef;
  late MockDatabaseReference mockUserUidRef;
  late MockDataSnapshot mockUserSnapshot;
  late MockDataSnapshot mockUsersSnapshot;
  late UsersRepositoryImpl repository;

  setUp(() {
    mockDb = MockFirebaseDatabase();
    mockRef = MockDatabaseReference();
    mockUsersRef = MockDatabaseReference();
    mockUserUidRef = MockDatabaseReference();
    mockUserSnapshot = MockDataSnapshot();
    mockUsersSnapshot = MockDataSnapshot();

    when(() => mockDb.ref()).thenReturn(mockRef);
    when(() => mockDb.ref(any())).thenReturn(mockUsersRef);
    when(() => mockRef.child('users')).thenReturn(mockUsersRef);
    when(() => mockUsersRef.onValue).thenAnswer((_) => const Stream<DatabaseEvent>.empty());
    when(() => mockUsersRef.child(any())).thenReturn(mockUserUidRef);
    when(() => mockUserUidRef.onValue).thenAnswer((_) => const Stream<DatabaseEvent>.empty());

    repository = UsersRepositoryImpl(
      FirebaseDatabaseService<UserEntity>(mockUsersRef),
    );
  });

  group('UserRepositoryImpl Tests', () {
    test('getUser returns UserEntity when data exists in DB', () async {
      when(() => mockUserUidRef.get()).thenAnswer((_) async => mockUserSnapshot);
      when(() => mockUserSnapshot.exists).thenReturn(true);
      when(() => mockUserSnapshot.value).thenReturn({
        'name': 'Test User',
        'email': 'test@example.com',
        'role': 'admin',
        'isActive': true,
        'permissions': {'manage_users': true},
      });

      final user = await repository.getUser('uid_123');

      expect(user, isNotNull);
      expect(user!.uid, 'uid_123');
      expect(user.name, 'Test User');
      expect(user.email, 'test@example.com');
      expect(user.role, UserRole.admin);
      expect(user.isActive, isTrue);
      expect(user.hasPermission(UserPermission.manageUsers), isTrue);
    });

    test('getUser returns null when user does not exist in DB', () async {
      when(() => mockUserUidRef.get()).thenAnswer((_) async => mockUserSnapshot);
      when(() => mockUserSnapshot.exists).thenReturn(false);

      final user = await repository.getUser('non_existing_uid');

      expect(user, isNull);
    });

    test('saveUser updates user node in DB', () async {
      when(() => mockUserUidRef.set(any())).thenAnswer((_) async {});

      const userToSave = UserEntity(
        uid: 'uid_123',
        name: 'Saved User',
        email: 'saved@example.com',
        role: UserRole.seller,
        isActive: true,
        permissions: {},
      );

      await repository.saveUser(userToSave);

      verify(() => mockUserUidRef.set(any())).called(1);
    });

    test('deleteUser removes user node from DB', () async {
      when(() => mockUserUidRef.remove()).thenAnswer((_) async {});

      await repository.deleteUser('uid_123');

      verify(() => mockUserUidRef.remove()).called(1);
    });

    test('getAllUsers returns list of UserEntity when database contains users', () async {
      when(() => mockUsersRef.get()).thenAnswer((_) async => mockUsersSnapshot);
      when(() => mockUsersSnapshot.exists).thenReturn(true);
      when(() => mockUsersSnapshot.value).thenReturn({
        'user_1': {
          'name': 'User 1',
          'email': 'user1@example.com',
          'role': 'owner',
          'isActive': true,
        },
        'user_2': {
          'name': 'User 2',
          'email': 'user2@example.com',
          'role': 'seller',
          'isActive': false,
        },
      });

      final users = await repository.getAllUsers();

      expect(users.length, 2);
      expect(users.map((u) => u.uid), containsAll(['user_1', 'user_2']));
    });
  });
}
