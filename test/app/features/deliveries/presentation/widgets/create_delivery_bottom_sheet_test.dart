import 'package:estoque_pro/app/core/services/authorization_service.dart';
import 'package:estoque_pro/app/features/auth/domain/repositories/auth_repository.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:estoque_pro/app/features/customers/domain/entities/customer_entity.dart';
import 'package:estoque_pro/app/features/customers/domain/repositories/customers_repository.dart';
import 'package:estoque_pro/app/features/deliveries/domain/entities/delivery_entity.dart';
import 'package:estoque_pro/app/features/deliveries/domain/entities/delivery_status.dart';
import 'package:estoque_pro/app/features/deliveries/domain/repositories/deliveries_repository.dart';
import 'package:estoque_pro/app/features/deliveries/presentation/viewmodels/deliveries_viewmodel.dart';
import 'package:estoque_pro/app/features/deliveries/presentation/widgets/create_delivery_bottom_sheet.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/discount_type.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/payment_method.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_item_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_status.dart';
import 'package:estoque_pro/app/features/sales/domain/repositories/sales_repository.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_entity.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_role.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockAuthorizationService extends Mock implements AuthorizationService {}
class MockSalesRepository extends Mock implements SalesRepository {}
class MockDeliveriesRepository extends Mock implements DeliveriesRepository {}
class MockCustomersRepository extends Mock implements CustomersRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockAuthorizationService mockAuthService;
  late MockSalesRepository mockSalesRepository;
  late MockDeliveriesRepository mockDeliveriesRepository;
  late MockCustomersRepository mockCustomersRepository;

  late AuthViewModel authViewModel;
  late DeliveriesViewModel deliveriesViewModel;

  final now = DateTime(2026, 8, 25, 10, 0);

  final saleWithoutDelivery = SaleEntity(
    id: 's1',
    saleNumber: 'A1B2C3',
    items: const [
      SaleItemEntity(
        productId: 'p1',
        productName: 'Camisa Polo',
        productImgUrl: '',
        unitPrice: 50.0,
        quantity: 2,
      ),
    ],
    subtotal: 100.0,
    discountType: DiscountType.valueAmount,
    discountValue: 0.0,
    total: 100.0,
    paymentMethod: PaymentMethod.pix,
    customerId: 'c1',
    customerName: 'Maria Silva',
    userId: 'u1',
    userName: 'Vendedor',
    status: SaleStatus.completed,
    createdAt: now,
  );

  final saleWithDelivery = SaleEntity(
    id: 's2',
    saleNumber: 'D4E5F6',
    items: const [
      SaleItemEntity(
        productId: 'p2',
        productName: 'Calça Jeans',
        productImgUrl: '',
        unitPrice: 120.0,
        quantity: 1,
      ),
    ],
    subtotal: 120.0,
    discountType: DiscountType.valueAmount,
    discountValue: 0.0,
    total: 120.0,
    paymentMethod: PaymentMethod.dinheiro,
    customerId: 'c2',
    customerName: 'Carlos Souza',
    userId: 'u1',
    userName: 'Vendedor',
    status: SaleStatus.completed,
    createdAt: now,
  );

  final existingDelivery = DeliveryEntity(
    id: 'd1',
    saleId: 's2',
    saleNumber: 'D4E5F6',
    customerId: 'c2',
    customerName: 'Carlos Souza',
    customerAddress: 'Av Principal, 456',
    items: const [],
    subtotal: 120.0,
    totalAmount: 120.0,
    paymentMethod: PaymentMethod.dinheiro,
    status: DeliveryStatus.pending,
    scheduledAt: now.add(const Duration(hours: 2)),
    userId: 'u1',
    userName: 'Vendedor',
    createdAt: now,
  );

  setUpAll(() async {
    await initializeDateFormatting('pt_BR', null);
    registerFallbackValue(existingDelivery);
  });

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockAuthService = MockAuthorizationService();
    mockSalesRepository = MockSalesRepository();
    mockDeliveriesRepository = MockDeliveriesRepository();
    mockCustomersRepository = MockCustomersRepository();

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

    when(() => mockDeliveriesRepository.watchAll()).thenAnswer((_) => Stream.value([existingDelivery]));
    when(() => mockDeliveriesRepository.save(any())).thenAnswer((_) async {});

    when(() => mockSalesRepository.watchAll()).thenAnswer((_) => Stream.value([saleWithoutDelivery, saleWithDelivery]));
    when(() => mockCustomersRepository.getAll()).thenAnswer((_) async => [
      const CustomerEntity(
        id: 'c1',
        name: 'Maria Silva',
        address: 'Rua das Palmeiras, 100',
        phone: '11988887777',
      ),
    ]);

    authViewModel = AuthViewModel(mockAuthRepository, mockAuthService);
    deliveriesViewModel = DeliveriesViewModel(mockDeliveriesRepository)..listenAll();
  });

  testWidgets('CreateDeliveryBottomSheet shows only sales that do not have a delivery yet', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => CreateDeliveryBottomSheet.show(
                context: context,
                deliveriesViewModel: deliveriesViewModel,
                authViewModel: authViewModel,
                salesRepository: mockSalesRepository,
                customersRepository: mockCustomersRepository,
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    // Deve exibir apenas a venda s1 (sem entrega)
    expect(find.text('#A1B2C3'), findsOneWidget);
    expect(find.text('Maria Silva'), findsOneWidget);

    // Não deve exibir a venda s2 (já possui entrega d1)
    expect(find.text('#D4E5F6'), findsNothing);
  });

  testWidgets('Selecting a sale opens the delivery form prefilled with customer address and saves delivery', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => CreateDeliveryBottomSheet.show(
                context: context,
                deliveriesViewModel: deliveriesViewModel,
                authViewModel: authViewModel,
                salesRepository: mockSalesRepository,
                customersRepository: mockCustomersRepository,
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    // Clica na venda A1B2C3
    await tester.tap(find.text('#A1B2C3'));
    await tester.pumpAndSettle();

    // Formulário de entrega deve ser exibido com endereço pré-preenchido
    expect(find.text('Dados da Entrega'), findsOneWidget);
    expect(find.text('Rua das Palmeiras, 100'), findsOneWidget);

    // Clica no botão Agendar Entrega
    await tester.ensureVisible(find.text('Agendar Entrega'));
    await tester.tap(find.text('Agendar Entrega'));
    await tester.pumpAndSettle();

    verify(() => mockDeliveriesRepository.save(any(that: isA<DeliveryEntity>()
        .having((d) => d.saleId, 'saleId', 's1')
        .having((d) => d.saleNumber, 'saleNumber', 'A1B2C3')
        .having((d) => d.customerAddress, 'customerAddress', 'Rua das Palmeiras, 100')))).called(1);
  });
}
