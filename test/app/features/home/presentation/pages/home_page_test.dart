import 'dart:async';
import 'package:estoque_pro/app/core/services/authorization_service.dart';
import 'package:estoque_pro/app/core/services/local_storage_service.dart';
import 'package:estoque_pro/app/features/auth/domain/repositories/auth_repository.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:estoque_pro/app/features/deliveries/domain/entities/delivery_entity.dart';
import 'package:estoque_pro/app/features/deliveries/domain/entities/delivery_status.dart';
import 'package:estoque_pro/app/features/deliveries/domain/repositories/deliveries_repository.dart';
import 'package:estoque_pro/app/features/deliveries/domain/usecases/delete_delivery_use_case.dart';
import 'package:estoque_pro/app/features/deliveries/domain/usecases/get_deliveries_use_case.dart';
import 'package:estoque_pro/app/features/deliveries/domain/usecases/save_delivery_use_case.dart';
import 'package:estoque_pro/app/features/deliveries/domain/usecases/update_delivery_status_use_case.dart';
import 'package:estoque_pro/app/features/deliveries/domain/usecases/update_delivery_use_case.dart';
import 'package:estoque_pro/app/features/deliveries/presentation/viewmodels/deliveries_viewmodel.dart';
import 'package:estoque_pro/app/features/home/presentation/pages/home_page.dart';
import 'package:estoque_pro/app/features/home/presentation/viewmodels/home_shortcuts_viewmodel.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_entity.dart';
import 'package:estoque_pro/app/features/products/domain/repositories/products_repository.dart';
import 'package:estoque_pro/app/features/products/domain/usecases/archive_product_use_case.dart';
import 'package:estoque_pro/app/features/products/domain/usecases/delete_product_permanently_use_case.dart';
import 'package:estoque_pro/app/features/products/domain/usecases/get_products_use_case.dart';
import 'package:estoque_pro/app/features/products/domain/usecases/unarchive_product_use_case.dart';
import 'package:estoque_pro/app/features/products/domain/usecases/watch_product_history_use_case.dart';
import 'package:estoque_pro/app/features/products/presentation/viewmodels/products_viewmodel.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/payment_method.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/repositories/sales_repository.dart';
import 'package:estoque_pro/app/features/sales/domain/usecases/delete_sale_use_case.dart';
import 'package:estoque_pro/app/features/sales/domain/usecases/get_sales_use_case.dart';
import 'package:estoque_pro/app/features/sales/presentation/viewmodels/sales_viewmodel.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_entity.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_role.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockAuthorizationService extends Mock implements AuthorizationService {}
class MockSalesRepository extends Mock implements SalesRepository {}
class MockProductsRepository extends Mock implements ProductsRepository {}
class MockDeliveriesRepository extends Mock implements DeliveriesRepository {}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('pt_BR', null);
  });

  late MockAuthRepository mockAuthRepository;
  late MockAuthorizationService mockAuthService;
  late MockSalesRepository mockSalesRepository;
  late MockProductsRepository mockProductsRepository;
  late MockDeliveriesRepository mockDeliveriesRepository;

  late StreamController<List<SaleEntity>> salesController;
  late StreamController<List<ProductEntity>> productsController;
  late StreamController<List<DeliveryEntity>> deliveriesController;

  late AuthViewModel authViewModel;
  late SalesViewModel salesViewModel;
  late ProductsViewModel productsViewModel;
  late DeliveriesViewModel deliveriesViewModel;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockAuthService = MockAuthorizationService();
    mockSalesRepository = MockSalesRepository();
    mockProductsRepository = MockProductsRepository();
    mockDeliveriesRepository = MockDeliveriesRepository();

    salesController = StreamController<List<SaleEntity>>.broadcast();
    productsController = StreamController<List<ProductEntity>>.broadcast();
    deliveriesController = StreamController<List<DeliveryEntity>>.broadcast();

    when(() => mockSalesRepository.watchAll()).thenAnswer((_) => salesController.stream);
    when(() => mockProductsRepository.watchAll()).thenAnswer((_) => productsController.stream);
    when(() => mockDeliveriesRepository.watchAll()).thenAnswer((_) => deliveriesController.stream);

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
    salesViewModel = SalesViewModel(
      GetSalesUseCase(mockSalesRepository),
      DeleteSaleUseCase(mockSalesRepository),
      GetDeliveriesUseCase(mockDeliveriesRepository),
    );
    productsViewModel = ProductsViewModel(
      GetProductsUseCase(mockProductsRepository),
      ArchiveProductUseCase(mockProductsRepository),
      UnarchiveProductUseCase(mockProductsRepository),
      DeleteProductPermanentlyUseCase(mockProductsRepository),
      WatchProductHistoryUseCase(mockProductsRepository),
    );
    deliveriesViewModel = DeliveriesViewModel(
      GetDeliveriesUseCase(mockDeliveriesRepository),
      SaveDeliveryUseCase(mockDeliveriesRepository),
      UpdateDeliveryUseCase(mockDeliveriesRepository),
      UpdateDeliveryStatusUseCase(mockDeliveriesRepository),
      DeleteDeliveryUseCase(mockDeliveriesRepository),
    );
  });

  tearDown(() {
    salesController.close();
    productsController.close();
    deliveriesController.close();
  });

  testWidgets('HomePage displays delayed and pending deliveries banners when present', (tester) async {
    final now = DateTime.now();

    final delayedDelivery = DeliveryEntity(
      id: 'del-1',
      saleId: 'sale-1',
      saleNumber: '#A1B2C3',
      customerId: 'cust-1',
      customerName: 'Cliente Atrasado',
      customerAddress: 'Rua 1',
      items: const [],
      subtotal: 50.0,
      totalAmount: 50.0,
      paymentMethod: PaymentMethod.pix,
      userId: '1',
      userName: 'João',
      status: DeliveryStatus.pending,
      scheduledAt: now.subtract(const Duration(hours: 2)), // atrasada
      createdAt: now.subtract(const Duration(days: 1)),
    );

    final pendingDelivery = DeliveryEntity(
      id: 'del-2',
      saleId: 'sale-2',
      saleNumber: '#D4E5F6',
      customerId: 'cust-2',
      customerName: 'Cliente Futuro',
      customerAddress: 'Rua 2',
      items: const [],
      subtotal: 80.0,
      totalAmount: 80.0,
      paymentMethod: PaymentMethod.dinheiro,
      userId: '1',
      userName: 'João',
      status: DeliveryStatus.pending,
      scheduledAt: now.add(const Duration(hours: 2)), // pendente no futuro
      createdAt: now,
    );

    final localStorageService = LocalStorageService();
    final shortcutsViewModel = HomeShortcutsViewModel(localStorageService);

    await tester.pumpWidget(
      MaterialApp(
        home: HomePage(
          authViewModel: authViewModel,
          salesViewModelFactory: () => salesViewModel,
          productsViewModelFactory: () => productsViewModel,
          deliveriesViewModelFactory: () => deliveriesViewModel,
          homeShortcutsViewModelFactory: () => shortcutsViewModel,
        ),
      ),
    );

    // Emite as entregas
    deliveriesController.add([delayedDelivery, pendingDelivery]);
    salesController.add([]);
    productsController.add([]);

    await tester.pumpAndSettle();

    // Verifica que os avisos aparecem na Home
    expect(find.text('Avisos'), findsOneWidget);
    expect(find.text('1 entrega atrasada'), findsOneWidget);
    expect(find.text('1 entrega pendente'), findsOneWidget);
  });
}
