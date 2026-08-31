import 'package:estoque_pro/app/core/services/authorization_service.dart';
import 'package:estoque_pro/app/features/auth/domain/repositories/auth_repository.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:estoque_pro/app/features/deliveries/domain/entities/delivery_entity.dart';
import 'package:estoque_pro/app/features/deliveries/domain/repositories/deliveries_repository.dart';
import 'package:estoque_pro/app/features/deliveries/domain/usecases/delete_delivery_use_case.dart';
import 'package:estoque_pro/app/features/deliveries/domain/usecases/get_deliveries_use_case.dart';
import 'package:estoque_pro/app/features/deliveries/domain/usecases/save_delivery_use_case.dart';
import 'package:estoque_pro/app/features/deliveries/domain/usecases/update_delivery_status_use_case.dart';
import 'package:estoque_pro/app/features/deliveries/domain/usecases/update_delivery_use_case.dart';
import 'package:estoque_pro/app/features/deliveries/presentation/viewmodels/deliveries_viewmodel.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/repositories/sales_repository.dart';
import 'package:estoque_pro/app/features/sales/domain/usecases/delete_sale_use_case.dart';
import 'package:estoque_pro/app/features/sales/domain/usecases/get_sales_use_case.dart';
import 'package:estoque_pro/app/features/sales/presentation/pages/sales_page.dart';
import 'package:estoque_pro/app/features/sales/presentation/viewmodels/sales_viewmodel.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_entity.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_role.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockAuthorizationService extends Mock implements AuthorizationService {}
class MockSalesRepository extends Mock implements SalesRepository {}
class MockDeliveriesRepository extends Mock implements DeliveriesRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockAuthorizationService mockAuthService;
  late MockSalesRepository mockSalesRepository;
  late MockDeliveriesRepository mockDeliveriesRepository;

  late AuthViewModel authViewModel;

  DeliveriesViewModel createDeliveriesViewModel() {
    return DeliveriesViewModel(
      GetDeliveriesUseCase(mockDeliveriesRepository),
      SaveDeliveryUseCase(mockDeliveriesRepository),
      UpdateDeliveryUseCase(mockDeliveriesRepository),
      UpdateDeliveryStatusUseCase(mockDeliveriesRepository),
      DeleteDeliveryUseCase(mockDeliveriesRepository),
    );
  }

  SalesViewModel createSalesViewModel() {
    return SalesViewModel(
      GetSalesUseCase(mockSalesRepository),
      DeleteSaleUseCase(mockSalesRepository),
      GetDeliveriesUseCase(mockDeliveriesRepository),
    );
  }

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockAuthService = MockAuthorizationService();
    mockSalesRepository = MockSalesRepository();
    mockDeliveriesRepository = MockDeliveriesRepository();

    when(() => mockSalesRepository.watchAll()).thenAnswer((_) => Stream.value(<SaleEntity>[]));
    when(() => mockDeliveriesRepository.watchAll(limit: any(named: 'limit')))
        .thenAnswer((_) => Stream.value(<DeliveryEntity>[]));

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

  testWidgets('SalesPage initializes viewModel via factory and sets initialTab when provided', (tester) async {
    late SalesViewModel createdVm;

    await tester.pumpWidget(
      MaterialApp(
        home: SalesPage(
          viewModelFactory: () {
            createdVm = createSalesViewModel();
            return createdVm;
          },
          deliveriesViewModelFactory: () => createDeliveriesViewModel(),
          authViewModel: authViewModel,
          initialTab: SalesFilterTab.inProgress,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Vendas'), findsOneWidget);
    expect(createdVm.selectedTab, SalesFilterTab.inProgress);
  });

  testWidgets('SalesPage defaults to SalesFilterTab.all when initialTab is null', (tester) async {
    late SalesViewModel createdVm;

    await tester.pumpWidget(
      MaterialApp(
        home: SalesPage(
          viewModelFactory: () {
            createdVm = createSalesViewModel();
            return createdVm;
          },
          deliveriesViewModelFactory: () => createDeliveriesViewModel(),
          authViewModel: authViewModel,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Vendas'), findsOneWidget);
    expect(createdVm.selectedTab, SalesFilterTab.all);
  });
}
