import 'package:estoque_pro/app/core/services/authorization_service.dart';
import 'package:estoque_pro/app/features/auth/domain/repositories/auth_repository.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:estoque_pro/app/features/customers/domain/repositories/customer_payments_repository.dart';
import 'package:estoque_pro/app/features/customers/domain/repositories/customers_repository.dart';
import 'package:estoque_pro/app/features/customers/domain/usecases/cancel_customer_payment_use_case.dart';
import 'package:estoque_pro/app/features/customers/domain/usecases/get_customer_payments_use_case.dart';
import 'package:estoque_pro/app/features/customers/domain/usecases/get_customers_use_case.dart';
import 'package:estoque_pro/app/features/customers/domain/usecases/register_customer_payment_use_case.dart';
import 'package:estoque_pro/app/features/customers/presentation/viewmodels/customer_debts_viewmodel.dart';
import 'package:estoque_pro/app/features/customers/presentation/viewmodels/customers_viewmodel.dart';
import 'package:estoque_pro/app/features/sales/domain/usecases/get_sales_use_case.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_entity.dart';
import 'package:estoque_pro/app/features/products/domain/repositories/products_repository.dart';
import 'package:estoque_pro/app/features/products/domain/usecases/archive_product_use_case.dart';
import 'package:estoque_pro/app/features/products/domain/usecases/delete_product_permanently_use_case.dart';
import 'package:estoque_pro/app/features/products/domain/usecases/get_products_use_case.dart';
import 'package:estoque_pro/app/features/products/domain/usecases/unarchive_product_use_case.dart';
import 'package:estoque_pro/app/features/products/domain/usecases/watch_product_history_use_case.dart';
import 'package:estoque_pro/app/features/products/presentation/viewmodels/products_viewmodel.dart';
import 'package:estoque_pro/app/features/sales/domain/repositories/sales_repository.dart';
import 'package:estoque_pro/app/features/sales/domain/usecases/finalize_sale_use_case.dart';
import 'package:estoque_pro/app/features/sales/domain/usecases/save_draft_sale_use_case.dart';
import 'package:estoque_pro/app/features/sales/presentation/pages/new_sale_page.dart';
import 'package:estoque_pro/app/features/sales/presentation/viewmodels/cart_viewmodel.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_entity.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_role.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockAuthorizationService extends Mock implements AuthorizationService {}
class MockProductsRepository extends Mock implements ProductsRepository {}
class MockCustomersRepository extends Mock implements CustomersRepository {}
class MockSalesRepository extends Mock implements SalesRepository {}
class MockCustomerPaymentsRepository extends Mock implements CustomerPaymentsRepository {}
class MockFinalizeSaleUseCase extends Mock implements FinalizeSaleUseCase {}
class MockSaveDraftSaleUseCase extends Mock implements SaveDraftSaleUseCase {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockAuthorizationService mockAuthService;
  late MockProductsRepository mockProductsRepository;
  late MockCustomersRepository mockCustomersRepository;
  late MockSalesRepository mockSalesRepository;
  late MockCustomerPaymentsRepository mockPaymentsRepository;
  late MockFinalizeSaleUseCase mockFinalizeSaleUseCase;
  late MockSaveDraftSaleUseCase mockSaveDraftSaleUseCase;

  late AuthViewModel authViewModel;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockAuthService = MockAuthorizationService();
    mockProductsRepository = MockProductsRepository();
    mockCustomersRepository = MockCustomersRepository();
    mockSalesRepository = MockSalesRepository();
    mockPaymentsRepository = MockCustomerPaymentsRepository();
    mockFinalizeSaleUseCase = MockFinalizeSaleUseCase();
    mockSaveDraftSaleUseCase = MockSaveDraftSaleUseCase();

    when(() => mockProductsRepository.watchAll()).thenAnswer((_) => Stream.value(<ProductEntity>[]));
    when(() => mockCustomersRepository.watchAll()).thenAnswer((_) => const Stream.empty());
    when(() => mockSalesRepository.watchAll()).thenAnswer((_) => const Stream.empty());
    when(() => mockPaymentsRepository.watchAll()).thenAnswer((_) => const Stream.empty());

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

  testWidgets('NewSalePage instantiates productsViewModel and cartViewModel via factory functions', (tester) async {
    late ProductsViewModel createdProductsVm;
    late CartViewModel createdCartVm;

    await tester.pumpWidget(
      MaterialApp(
        home: NewSalePage(
          productsViewModelFactory: () {
            createdProductsVm = ProductsViewModel(
              GetProductsUseCase(mockProductsRepository),
              ArchiveProductUseCase(mockProductsRepository),
              UnarchiveProductUseCase(mockProductsRepository),
              DeleteProductPermanentlyUseCase(mockProductsRepository),
              WatchProductHistoryUseCase(mockProductsRepository),
            );
            return createdProductsVm;
          },
          cartViewModelFactory: () {
            createdCartVm = CartViewModel(mockFinalizeSaleUseCase, mockSaveDraftSaleUseCase);
            return createdCartVm;
          },
          customersViewModelFactory: () => CustomersViewModel(GetCustomersUseCase(mockCustomersRepository)),
          debtsViewModelFactory: () => CustomerDebtsViewModel(
            GetSalesUseCase(mockSalesRepository),
            GetCustomerPaymentsUseCase(mockPaymentsRepository),
            RegisterCustomerPaymentUseCase(mockPaymentsRepository),
            CancelCustomerPaymentUseCase(mockPaymentsRepository),
          ),
          authViewModel: authViewModel,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Nova Venda'), findsOneWidget);
    expect(createdProductsVm, isNotNull);
    expect(createdCartVm, isNotNull);
  });
}
