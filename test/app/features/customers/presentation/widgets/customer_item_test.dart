import 'package:estoque_pro/app/features/auth/domain/repositories/auth_repository.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:estoque_pro/app/core/services/authorization_service.dart';
import 'package:estoque_pro/app/features/customers/domain/entities/customer_entity.dart';
import 'package:estoque_pro/app/features/customers/domain/entities/customer_summary_entity.dart';
import 'package:estoque_pro/app/features/customers/domain/repositories/customer_payments_repository.dart';
import 'package:estoque_pro/app/features/customers/presentation/viewmodels/customer_debts_viewmodel.dart';
import 'package:estoque_pro/app/features/customers/presentation/widgets/customer_item.dart';
import 'package:estoque_pro/app/features/sales/domain/repositories/sales_repository.dart';
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

  setUp(() {
    mockSalesRepo = MockSalesRepository();
    mockPaymentsRepo = MockCustomerPaymentsRepository();
    mockAuthRepo = MockAuthRepository();
    mockAuthService = MockAuthorizationService();

    when(() => mockSalesRepo.watchAll()).thenAnswer((_) => const Stream.empty());
    when(() => mockPaymentsRepo.watchAll()).thenAnswer((_) => const Stream.empty());
    when(() => mockAuthRepo.authStateChanges).thenAnswer((_) => const Stream.empty());
    when(() => mockAuthRepo.currentUser).thenReturn(null);
    when(() => mockAuthService.currentUser).thenReturn(null);

    debtsViewModel = CustomerDebtsViewModel(mockSalesRepo, mockPaymentsRepo);
    authViewModel = AuthViewModel(mockAuthRepo, mockAuthService);
  });

  const testCustomer = CustomerEntity(
    id: 'c1',
    name: 'João Silva',
    address: 'Rua das Palmeiras, 100',
    phone: '11988887777',
  );

  testWidgets('CustomerItem displays customer name, address, purchase count, and debt badge when customer has debt', (tester) async {
    const debtSummary = CustomerSummaryEntity(
      customerId: 'c1',
      totalPurchasesCount: 3,
      totalDebt: 150.0,
      totalPaid: 50.0,
      currentDebt: 100.0,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomerItem(
            customer: testCustomer,
            summary: debtSummary,
            debtsViewModel: debtsViewModel,
            authViewModel: authViewModel,
          ),
        ),
      ),
    );

    expect(find.text('João Silva'), findsOneWidget);
    expect(find.text('Rua das Palmeiras, 100'), findsOneWidget);
    expect(find.text('3 compras'), findsOneWidget);
    expect(find.text('Deve R\$ 100,00'), findsOneWidget);
  });

  testWidgets('CustomerItem displays Sem débitos when customer has zero debt', (tester) async {
    const zeroDebtSummary = CustomerSummaryEntity(
      customerId: 'c1',
      totalPurchasesCount: 1,
      totalDebt: 50.0,
      totalPaid: 50.0,
      currentDebt: 0.0,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomerItem(
            customer: testCustomer,
            summary: zeroDebtSummary,
            debtsViewModel: debtsViewModel,
            authViewModel: authViewModel,
          ),
        ),
      ),
    );

    expect(find.text('1 compra'), findsOneWidget);
    expect(find.text('Sem débitos'), findsOneWidget);
  });
}
