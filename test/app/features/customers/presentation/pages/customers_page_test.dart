import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/features/auth/domain/repositories/auth_repository.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:estoque_pro/app/core/services/authorization_service.dart';
import 'package:estoque_pro/app/features/customers/domain/entities/customer_entity.dart';
import 'package:estoque_pro/app/features/customers/domain/repositories/customers_repository.dart';
import 'package:estoque_pro/app/features/customers/presentation/pages/customers_page.dart';
import 'package:estoque_pro/app/features/customers/presentation/viewmodels/customers_viewmodel.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_entity.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_permission.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_role.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockAuthorizationService extends Mock implements AuthorizationService {}
class MockCustomersRepository extends Mock implements CustomersRepository {}

void main() {
  late MockAuthRepository mockAuthRepo;
  late MockAuthorizationService mockAuthService;
  late MockCustomersRepository mockCustomersRepo;

  setUp(() {
    mockAuthRepo = MockAuthRepository();
    mockAuthService = MockAuthorizationService();
    mockCustomersRepo = MockCustomersRepository();

    when(() => mockCustomersRepo.watchAll()).thenAnswer((_) => Stream.value(<CustomerEntity>[]));
    when(() => mockAuthRepo.authStateChanges).thenAnswer((_) => const Stream.empty());
    when(() => mockAuthRepo.currentUser).thenReturn(null);
  });

  Widget createWidgetUnderTest(AuthViewModel authViewModel) {
    return MaterialApp(
      home: CustomersPage(
        viewModelFactory: () => CustomersViewModel(mockCustomersRepo),
        authViewModel: authViewModel,
      ),
    );
  }

  testWidgets('FAB is NOT displayed when seller does NOT have managerCustomer permission', (tester) async {
    const sellerWithoutPermission = UserEntity(
      uid: 'seller_1',
      name: 'Vendedor Sem Permissão',
      email: 'seller@test.com',
      role: UserRole.seller,
      isActive: true,
      permissions: {}, // No managerCustomer permission
    );

    when(() => mockAuthService.currentUser).thenReturn(sellerWithoutPermission);
    final authViewModel = AuthViewModel(mockAuthRepo, mockAuthService);

    await tester.pumpWidget(createWidgetUnderTest(authViewModel));
    await tester.pumpAndSettle();

    expect(find.byType(AppFloatingActionButton), findsNothing);
  });

  testWidgets('FAB IS displayed when seller HAS managerCustomer permission', (tester) async {
    const sellerWithPermission = UserEntity(
      uid: 'seller_2',
      name: 'Vendedor Com Permissão',
      email: 'seller@test.com',
      role: UserRole.seller,
      isActive: true,
      permissions: {UserPermission.managerCustomer},
    );

    when(() => mockAuthService.currentUser).thenReturn(sellerWithPermission);
    final authViewModel = AuthViewModel(mockAuthRepo, mockAuthService);

    await tester.pumpWidget(createWidgetUnderTest(authViewModel));
    await tester.pumpAndSettle();

    expect(find.byType(AppFloatingActionButton), findsOneWidget);
  });

  testWidgets('FAB IS displayed when user is owner', (tester) async {
    const ownerUser = UserEntity(
      uid: 'owner_1',
      name: 'Dono',
      email: 'owner@test.com',
      role: UserRole.owner,
      isActive: true,
      permissions: {},
    );

    when(() => mockAuthService.currentUser).thenReturn(ownerUser);
    final authViewModel = AuthViewModel(mockAuthRepo, mockAuthService);

    await tester.pumpWidget(createWidgetUnderTest(authViewModel));
    await tester.pumpAndSettle();

    expect(find.byType(AppFloatingActionButton), findsOneWidget);
  });
}
