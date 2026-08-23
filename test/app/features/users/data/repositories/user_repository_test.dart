import 'package:estoque_pro/app/core/services/firebase_database_service.dart';
import 'package:estoque_pro/app/features/users/data/repositories/users_repository_impl.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_entity.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_role.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseDatabase extends Mock implements FirebaseDatabase {}

class MockDatabaseReference extends Mock implements DatabaseReference {}

class MockDataSnapshot extends Mock implements DataSnapshot {}

void main() {
  late MockFirebaseDatabase mockDb;
  late MockDatabaseReference mockRoot;
  late MockDatabaseReference mockUsersRef;
  late MockDatabaseReference mockUserUidRef;
  late MockDataSnapshot mockUserSnapshot;
  late MockDataSnapshot mockUsersSnapshot;
  late UsersRepositoryImpl repository;

  setUp(() {
    mockDb = MockFirebaseDatabase();
    mockRoot = MockDatabaseReference();
    mockUsersRef = MockDatabaseReference();
    mockUserUidRef = MockDatabaseReference();
    mockUserSnapshot = MockDataSnapshot();
    mockUsersSnapshot = MockDataSnapshot();

    when(() => mockDb.ref()).thenReturn(mockRoot);
    when(() => mockDb.ref('users')).thenReturn(mockUsersRef);
    when(() => mockUsersRef.root).thenReturn(mockRoot);
    when(() => mockRoot.update(any())).thenAnswer((_) async {});

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
    });

    test('getUser returns null when user does not exist in DB', () async {
      when(() => mockUserUidRef.get()).thenAnswer((_) async => mockUserSnapshot);
      when(() => mockUserSnapshot.exists).thenReturn(false);
      when(() => mockUserSnapshot.value).thenReturn(null);

      final user = await repository.getUser('non_existing_uid');

      expect(user, isNull);
    });

    test('saveUser updates user node in DB', () async {
      const userToSave = UserEntity(
        uid: 'uid_123',
        name: 'Saved User',
        email: 'saved@example.com',
        role: UserRole.seller,
        isActive: true,
        permissions: {},
      );

      await repository.saveUser(userToSave);

      final captured = verify(() => mockRoot.update(captureAny())).captured;
      final written = captured.first as Map<String, dynamic>;
      expect(written.containsKey('users/uid_123'), isTrue);
      expect(written.containsKey('user_roles/uid_123'), isTrue);
      expect(written.containsKey('user_permissions/uid_123'), isTrue);
    });

    test('deleteUser removes user node from DB', () async {
      await repository.deleteUser('uid_123');

      final captured = verify(() => mockRoot.update(captureAny())).captured;
      final written = captured.first as Map<String, dynamic>;
      expect(written['users/uid_123'], isNull);
      expect(written['user_roles/uid_123'], isNull);
      expect(written['user_permissions/uid_123'], isNull);
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
