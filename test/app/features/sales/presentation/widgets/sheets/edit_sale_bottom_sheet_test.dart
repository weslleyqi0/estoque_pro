import 'package:estoque_pro/app/core/services/authorization_service.dart';
import 'package:estoque_pro/app/core/utils/result.dart';
import 'package:estoque_pro/app/features/auth/domain/repositories/auth_repository.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:estoque_pro/app/features/customers/domain/entities/customer_entity.dart';
import 'package:estoque_pro/app/features/products/domain/repositories/products_repository.dart';
import 'package:estoque_pro/app/features/products/domain/usecases/get_products_use_case.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/payment_method.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_edit_history_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_item_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_status.dart';
import 'package:estoque_pro/app/features/sales/domain/usecases/cancel_completed_sale_use_case.dart';
import 'package:estoque_pro/app/features/sales/domain/usecases/edit_sale_use_case.dart';
import 'package:estoque_pro/app/features/sales/presentation/viewmodels/edit_sale_viewmodel.dart';
import 'package:estoque_pro/app/features/sales/presentation/widgets/sheets/edit_sale_bottom_sheet.dart';
import 'package:estoque_pro/app/features/sales/domain/repositories/sales_repository.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_entity.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_permission.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_role.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class FakeSaleEditHistoryEntity extends Fake implements SaleEditHistoryEntity {}
class MockSalesRepository extends Mock implements SalesRepository {}
class MockEditSaleUseCase extends Mock implements EditSaleUseCase {}
class MockCancelCompletedSaleUseCase extends Mock implements CancelCompletedSaleUseCase {}
class MockProductsRepository extends Mock implements ProductsRepository {}
class MockAuthRepository extends Mock implements AuthRepository {}
class MockAuthorizationService extends Mock implements AuthorizationService {}

void main() {
  late MockEditSaleUseCase mockEditSaleUseCase;
  late MockCancelCompletedSaleUseCase mockCancelUseCase;
  late MockProductsRepository mockProductsRepository;
  late MockAuthRepository mockAuthRepo;
  late MockAuthorizationService mockAuthService;
  late AuthViewModel authViewModel;

  final fixedDate = DateTime(2026, 8, 26, 14, 0);

  const testUser = UserEntity(
    uid: 'u1',
    name: 'Admin User',
    email: 'admin@test.com',
    role: UserRole.admin,
    isActive: true,
    permissions: {
      UserPermission.editSales,
      UserPermission.cancelCompletedSales,
      UserPermission.managerCustomer,
    },
  );

  final initialSale = SaleEntity(
    id: 's1',
    saleNumber: 'VENDA-001',
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
    total: 100.0,
    paymentMethod: PaymentMethod.dinheiro,
    customerId: 'c1',
    customerName: 'João da Silva',
    userId: 'u1',
    userName: 'Admin User',
    status: SaleStatus.completed,
    createdAt: fixedDate,
  );

  setUpAll(() {
    registerFallbackValue(testUser);
    registerFallbackValue(initialSale);
    registerFallbackValue(FakeSaleEditHistoryEntity());
  });

  setUp(() {
    mockEditSaleUseCase = MockEditSaleUseCase();
    mockCancelUseCase = MockCancelCompletedSaleUseCase();
    mockProductsRepository = MockProductsRepository();
    mockAuthRepo = MockAuthRepository();
    mockAuthService = MockAuthorizationService();

    when(() => mockAuthService.currentUser).thenReturn(testUser);
    when(() => mockAuthRepo.currentUser).thenReturn(null);
    when(() => mockAuthRepo.authStateChanges).thenAnswer((_) => const Stream.empty());

    authViewModel = AuthViewModel(mockAuthRepo, mockAuthService);
    when(() => mockProductsRepository.getAll()).thenAnswer((_) async => const Result.success([]));
  });

  test('EditSaleViewModel setCustomer updates customerId and customerName and marks hasChanges', () {
    final vm = EditSaleViewModel(
      mockEditSaleUseCase,
      mockCancelUseCase,
      GetProductsUseCase(mockProductsRepository),
    )..initWithSale(initialSale);

    expect(vm.selectedCustomerId, 'c1');
    expect(vm.selectedCustomerName, 'João da Silva');
    expect(vm.hasChanges, isFalse);

    const newCustomer = CustomerEntity(
      id: 'c2',
      name: 'Maria Oliveira',
    );

    vm.setCustomer(id: newCustomer.id, name: newCustomer.name);

    expect(vm.selectedCustomerId, 'c2');
    expect(vm.selectedCustomerName, 'Maria Oliveira');
    expect(vm.hasChanges, isTrue);
  });

  testWidgets('EditSaleBottomSheet renders customer card and allows changing customer', (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final vm = EditSaleViewModel(
      mockEditSaleUseCase,
      mockCancelUseCase,
      GetProductsUseCase(mockProductsRepository),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => EditSaleBottomSheet.show(
                context,
                initialSale,
                authViewModel: authViewModel,
                viewModelFactory: () => vm,
              ),
              child: const Text('Open Sale Edit'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Sale Edit'));
    await tester.pumpAndSettle();

    expect(find.text('Editar Venda VENDA-001'), findsOneWidget);
    expect(find.text('Cliente da Venda'), findsOneWidget);
    expect(find.text('João da Silva'), findsOneWidget);
    expect(find.text('Trocar'), findsOneWidget);
    expect(find.text('Cancelar Venda'), findsOneWidget);
  });

  testWidgets('EditSaleBottomSheet allows cancelling sale with confirmation dialog', (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    when(() => mockCancelUseCase.call(
      sale: any(named: 'sale'),
      reason: any(named: 'reason'),
      comment: any(named: 'comment'),
      currentUser: any(named: 'currentUser'),
    )).thenAnswer((_) async => Result.success(initialSale.copyWith(status: SaleStatus.cancelled)));

    final vm = EditSaleViewModel(
      mockEditSaleUseCase,
      mockCancelUseCase,
      GetProductsUseCase(mockProductsRepository),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => EditSaleBottomSheet.show(
                context,
                initialSale,
                authViewModel: authViewModel,
                viewModelFactory: () => vm,
              ),
              child: const Text('Open Sale Edit'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Sale Edit'));
    await tester.pumpAndSettle();

    // Tap 'Cancelar Venda' button in footer
    await tester.tap(find.text('Cancelar Venda'));
    await tester.pumpAndSettle();

    // Confirmation dialog should be visible
    expect(find.text('Cancelar Venda'), findsWidgets);
    expect(find.text('Sim, Cancelar Venda'), findsOneWidget);

    // Confirm cancellation
    await tester.tap(find.text('Sim, Cancelar Venda'));
    await tester.pumpAndSettle();

    verify(() => mockCancelUseCase.call(
      sale: any(named: 'sale'),
      reason: any(named: 'reason'),
      comment: any(named: 'comment'),
      currentUser: any(named: 'currentUser'),
    )).called(1);

    // Bottom sheet is closed
    expect(find.text('Editar Venda VENDA-001'), findsNothing);
  });

  test('EditSaleUseCase does not append to editHistory when only customer changes', () async {
    final mockSalesRepo = MockSalesRepository();
    final mockProductsRepo = MockProductsRepository();
    when(() => mockProductsRepo.getAll()).thenAnswer((_) async => const Result.success([]));
    when(() => mockSalesRepo.updateSale(any())).thenAnswer((_) async => Result.success(initialSale));

    final useCase = EditSaleUseCase(mockSalesRepo, mockProductsRepo);

    final result = await useCase.call(
      originalSale: initialSale,
      updatedItems: initialSale.items,
      reason: 'Troca de cliente',
      customerId: 'c99',
      customerName: 'Novo Cliente',
      currentUser: testUser,
    );

    expect(result.isSuccess, isTrue);
    final updatedSale = result.value!;
    expect(updatedSale.customerId, 'c99');
    expect(updatedSale.customerName, 'Novo Cliente');
    // Histórico permanece vazio pois itens não mudaram
    expect(updatedSale.editHistory, isEmpty);

    verify(() => mockSalesRepo.updateSale(any(that: isA<SaleEntity>()
        .having((s) => s.customerId, 'customerId', 'c99')
        .having((s) => s.customerName, 'customerName', 'Novo Cliente')))).called(1);
    verifyNever(() => mockSalesRepo.updateSaleWithStockAndHistory(
      sale: any(named: 'sale'),
      stockDeltas: any(named: 'stockDeltas'),
      editHistoryEntry: any(named: 'editHistoryEntry'),
    ));
  });
}
