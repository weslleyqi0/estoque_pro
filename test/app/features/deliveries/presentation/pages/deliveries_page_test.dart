import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/core/services/authorization_service.dart';
import 'package:estoque_pro/app/features/auth/domain/repositories/auth_repository.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:estoque_pro/app/features/deliveries/domain/entities/delivery_entity.dart';
import 'package:estoque_pro/app/features/deliveries/domain/repositories/deliveries_repository.dart';
import 'package:estoque_pro/app/features/deliveries/presentation/pages/deliveries_page.dart';
import 'package:estoque_pro/app/features/deliveries/presentation/viewmodels/deliveries_viewmodel.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_entity.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_role.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockAuthorizationService extends Mock implements AuthorizationService {}
class MockDeliveriesRepository extends Mock implements DeliveriesRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockAuthorizationService mockAuthService;
  late MockDeliveriesRepository mockDeliveriesRepository;

  late AuthViewModel authViewModel;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockAuthService = MockAuthorizationService();
    mockDeliveriesRepository = MockDeliveriesRepository();

    when(() => mockDeliveriesRepository.watchAll()).thenAnswer((_) => Stream.value(<DeliveryEntity>[]));

    const currentUser = UserEntity(
      uid: '1',
      name: 'João Silva',
      email: 'joao@test.com',
      role: UserRole.owner,
      isActive: true,
      permissions: {},
    );
    when(() => mockAuthService.currentUser).thenReturn(currentUser);
    when(() => mockAuthRepository.currentUser).thenReturn(null);
    when(() => mockAuthRepository.authStateChanges).thenAnswer((_) => const Stream.empty());

    authViewModel = AuthViewModel(mockAuthRepository, mockAuthService);
  });

  testWidgets('DeliveriesPage initializes with initialTab selected when provided', (tester) async {
    late DeliveriesViewModel createdVm;

    await tester.pumpWidget(
      MaterialApp(
        home: DeliveriesPage(
          viewModelFactory: () {
            createdVm = DeliveriesViewModel(mockDeliveriesRepository);
            return createdVm;
          },
          authViewModel: authViewModel,
          initialTab: DeliveryFilterTab.delayed,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(createdVm.selectedTab, DeliveryFilterTab.delayed);
  });

  testWidgets('DeliveriesPage defaults to DeliveryFilterTab.all when initialTab is null', (tester) async {
    late DeliveriesViewModel createdVm;

    await tester.pumpWidget(
      MaterialApp(
        home: DeliveriesPage(
          viewModelFactory: () {
            createdVm = DeliveriesViewModel(mockDeliveriesRepository);
            return createdVm;
          },
          authViewModel: authViewModel,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(createdVm.selectedTab, DeliveryFilterTab.all);
  });

  testWidgets('DeliveriesPage displays FloatingActionButton for new delivery', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: DeliveriesPage(
          viewModelFactory: () => DeliveriesViewModel(mockDeliveriesRepository),
          authViewModel: authViewModel,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(AppFloatingActionButton), findsOneWidget);
  });
}
