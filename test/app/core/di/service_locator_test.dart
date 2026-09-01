import 'package:estoque_pro/app/core/di/modules/auth_module.dart';
import 'package:estoque_pro/app/core/di/modules/categories_module.dart';
import 'package:estoque_pro/app/core/di/modules/customers_module.dart';
import 'package:estoque_pro/app/core/di/modules/deliveries_module.dart';
import 'package:estoque_pro/app/core/di/modules/products_module.dart';
import 'package:estoque_pro/app/core/di/modules/sales_module.dart';
import 'package:estoque_pro/app/core/di/modules/suppliers_module.dart';
import 'package:estoque_pro/app/core/di/modules/users_module.dart';
import 'package:estoque_pro/app/core/services/database_service.dart';
import 'package:estoque_pro/app/core/services/local_storage_service.dart';
import 'package:estoque_pro/app/features/auth/domain/repositories/auth_repository.dart';
import 'package:estoque_pro/app/features/categories/domain/repositories/categories_repository.dart';
import 'package:estoque_pro/app/features/customers/domain/repositories/customers_repository.dart';
import 'package:estoque_pro/app/features/deliveries/domain/repositories/deliveries_repository.dart';
import 'package:estoque_pro/app/features/products/domain/repositories/products_repository.dart';
import 'package:estoque_pro/app/features/sales/domain/repositories/sales_repository.dart';
import 'package:estoque_pro/app/features/suppliers/domain/repositories/suppliers_repository.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_entity.dart';
import 'package:estoque_pro/app/features/users/domain/repositories/users_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockFirebaseDatabase extends Mock implements FirebaseDatabase {}
class MockDatabaseReference extends Mock implements DatabaseReference {}
class MockLocalStorageService extends Mock implements LocalStorageService {}

void main() {
  late GetIt sl;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockFirebaseDatabase mockFirebaseDatabase;
  late MockDatabaseReference mockDatabaseReference;
  late MockLocalStorageService mockLocalStorageService;

  setUp(() {
    sl = GetIt.asNewInstance();
    mockFirebaseAuth = MockFirebaseAuth();
    mockFirebaseDatabase = MockFirebaseDatabase();
    mockDatabaseReference = MockDatabaseReference();
    mockLocalStorageService = MockLocalStorageService();

    when(() => mockFirebaseDatabase.ref(any())).thenReturn(mockDatabaseReference);
    when(() => mockLocalStorageService.getBool(any(), defaultValue: any(named: 'defaultValue'))).thenReturn(false);

    sl.registerLazySingleton<FirebaseAuth>(() => mockFirebaseAuth);
    sl.registerLazySingleton<FirebaseDatabase>(() => mockFirebaseDatabase);
    sl.registerSingleton<LocalStorageService>(mockLocalStorageService);
  });

  tearDown(() async {
    await sl.reset();
  });

  group('Modular DI setup', () {
    test('setupUsersModule registers user dependencies', () {
      setupUsersModule(sl);

      expect(sl.isRegistered<DatabaseService<UserEntity>>(), isTrue);
      expect(sl.isRegistered<UsersRepository>(), isTrue);
    });

    test('setupCategoriesModule registers categories dependencies', () {
      setupCategoriesModule(sl);

      expect(sl.isRegistered<CategoriesRepository>(), isTrue);
    });

    test('setupSuppliersModule registers suppliers dependencies', () {
      setupSuppliersModule(sl);

      expect(sl.isRegistered<SuppliersRepository>(), isTrue);
    });

    test('setupCustomersModule registers customers dependencies', () {
      setupCustomersModule(sl);

      expect(sl.isRegistered<CustomersRepository>(), isTrue);
    });

    test('setupProductsModule registers products dependencies', () {
      setupProductsModule(sl);

      expect(sl.isRegistered<ProductsRepository>(), isTrue);
    });

    test('setupDeliveriesModule registers deliveries dependencies', () {
      setupDeliveriesModule(sl);

      expect(sl.isRegistered<DeliveriesRepository>(), isTrue);
    });

    test('setupSalesModule registers sales dependencies', () {
      setupProductsModule(sl);
      setupDeliveriesModule(sl);
      setupSalesModule(sl);

      expect(sl.isRegistered<SalesRepository>(), isTrue);
    });

    test('setupAuthModule registers auth dependencies', () {
      setupUsersModule(sl);
      setupAuthModule(sl);

      expect(sl.isRegistered<AuthRepository>(), isTrue);
    });
  });
}
