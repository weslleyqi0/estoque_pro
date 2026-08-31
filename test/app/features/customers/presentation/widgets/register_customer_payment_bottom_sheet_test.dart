import 'package:estoque_pro/app/core/utils/result.dart';
import 'package:estoque_pro/app/features/auth/domain/repositories/auth_repository.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:estoque_pro/app/core/services/authorization_service.dart';
import 'package:estoque_pro/app/features/customers/domain/entities/customer_entity.dart';
import 'package:estoque_pro/app/features/customers/domain/entities/customer_payment_entity.dart';
import 'package:estoque_pro/app/features/customers/domain/repositories/customer_payments_repository.dart';
import 'package:estoque_pro/app/features/customers/domain/usecases/cancel_customer_payment_use_case.dart';
import 'package:estoque_pro/app/features/customers/domain/usecases/get_customer_payments_use_case.dart';
import 'package:estoque_pro/app/features/customers/domain/usecases/register_customer_payment_use_case.dart';
import 'package:estoque_pro/app/features/customers/presentation/viewmodels/customer_debts_viewmodel.dart';
import 'package:estoque_pro/app/features/customers/presentation/widgets/register_customer_payment_bottom_sheet.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/payment_method.dart';
import 'package:estoque_pro/app/features/sales/domain/repositories/sales_repository.dart';
import 'package:estoque_pro/app/features/sales/domain/usecases/get_sales_use_case.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_entity.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_role.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSalesRepository extends Mock implements SalesRepository {}
class MockCustomerPaymentsRepository extends Mock implements CustomerPaymentsRepository {}
class MockAuthRepository extends Mock implements AuthRepository {}
class MockAuthorizationService extends Mock implements AuthorizationService {}

void main() {
  late MockSalesRepository mockSalesRepo;
  late MockCustomerPaymentsRepository mockPaymentsRepo;
  late MockAuthRepository mockAuthRepo;
  late MockAuthorizationService mockAuthService;
  late CustomerDebtsViewModel debtsViewModel;
  late AuthViewModel authViewModel;

  setUpAll(() {
    registerFallbackValue(
      CustomerPaymentEntity(
        id: '',
        customerId: 'c1',
        customerName: 'Cliente 1',
        amount: 10.0,
        paymentMethod: PaymentMethod.dinheiro,
        userId: 'u1',
        userName: 'User 1',
        createdAt: DateTime.now(),
      ),
    );
  });

  setUp(() {
    mockSalesRepo = MockSalesRepository();
    mockPaymentsRepo = MockCustomerPaymentsRepository();
    mockAuthRepo = MockAuthRepository();
    mockAuthService = MockAuthorizationService();

    when(() => mockSalesRepo.watchAll(limit: any(named: 'limit'))).thenAnswer((_) => const Stream.empty());
    when(() => mockPaymentsRepo.watchAll()).thenAnswer((_) => const Stream.empty());
    when(() => mockPaymentsRepo.save(any())).thenAnswer((_) async => const Result.success(null));
    when(() => mockAuthRepo.authStateChanges).thenAnswer((_) => const Stream.empty());
    when(() => mockAuthRepo.currentUser).thenReturn(null);

    const loggedUser = UserEntity(
      uid: 'user_10',
      name: 'Atendente Lucas',
      email: 'lucas@test.com',
      role: UserRole.seller,
      isActive: true,
      permissions: {},
    );
    when(() => mockAuthService.currentUser).thenReturn(loggedUser);

    debtsViewModel = CustomerDebtsViewModel(
      GetSalesUseCase(mockSalesRepo),
      GetCustomerPaymentsUseCase(mockPaymentsRepo),
      RegisterCustomerPaymentUseCase(mockPaymentsRepo),
      CancelCustomerPaymentUseCase(mockPaymentsRepo),
    );
    authViewModel = AuthViewModel(mockAuthRepo, mockAuthService);
  });

  const testCustomer = CustomerEntity(
    id: 'c1',
    name: 'José Pereira',
  );

  testWidgets('RegisterCustomerPaymentBottomSheet submits valid payment and displays operator name', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RegisterCustomerPaymentBottomSheet(
            customer: testCustomer,
            currentDebt: 120.0,
            debtsViewModel: debtsViewModel,
            authViewModel: authViewModel,
          ),
        ),
      ),
    );

    expect(find.text('Registrar Pagamento'), findsOneWidget);
    expect(find.text('José Pereira'), findsOneWidget);
    expect(find.text('Débito atual: R\$ 120,00'), findsOneWidget);
    expect(find.text('Registrado por: Atendente Lucas'), findsOneWidget);

    // Clica em PIX
    await tester.ensureVisible(find.text('PIX'));
    await tester.tap(find.text('PIX'));
    await tester.pumpAndSettle();

    // Rola até o botão e clica
    final buttonFinder = find.text('Confirmar Pagamento');
    await tester.ensureVisible(buttonFinder);
    await tester.tap(buttonFinder);
    await tester.pumpAndSettle();

    verify(() => mockPaymentsRepo.save(any(that: isA<CustomerPaymentEntity>()
        .having((p) => p.customerId, 'customerId', 'c1')
        .having((p) => p.amount, 'amount', 120.0)
        .having((p) => p.paymentMethod, 'paymentMethod', PaymentMethod.pix)
        .having((p) => p.userName, 'userName', 'Atendente Lucas')))).called(1);
  });
}
