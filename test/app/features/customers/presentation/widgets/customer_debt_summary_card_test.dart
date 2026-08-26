import 'package:estoque_pro/app/features/auth/domain/repositories/auth_repository.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:estoque_pro/app/core/services/authorization_service.dart';
import 'package:estoque_pro/app/features/customers/domain/entities/customer_entity.dart';
import 'package:estoque_pro/app/features/customers/domain/entities/customer_summary_entity.dart';
import 'package:estoque_pro/app/features/customers/domain/repositories/customer_payments_repository.dart';
import 'package:estoque_pro/app/features/customers/presentation/viewmodels/customer_debts_viewmodel.dart';
import 'package:estoque_pro/app/features/customers/presentation/widgets/customer_debt_summary_card.dart';
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
    name: 'Carlos Oliveira',
  );

  testWidgets('CustomerDebtSummaryCard displays metrics and Abater Dívida button when there is debt', (tester) async {
    const summary = CustomerSummaryEntity(
      customerId: 'c1',
      totalPurchasesCount: 5,
      totalDebt: 300.0,
      totalPaid: 100.0,
      currentDebt: 200.0,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomerDebtSummaryCard(
            customer: testCustomer,
            summary: summary,
            debtsViewModel: debtsViewModel,
            authViewModel: authViewModel,
          ),
        ),
      ),
    );

    expect(find.text('Resumo de Débitos'), findsOneWidget);
    expect(find.text('Débito Pendente'), findsOneWidget);
    expect(find.text('R\$ 200,00'), findsOneWidget);
    expect(find.text('5'), findsOneWidget); // Compras
    expect(find.text('R\$ 300,00'), findsOneWidget); // Total Fiado
    expect(find.text('R\$ 100,00'), findsOneWidget); // Total Pago
    expect(find.text('Abater Dívida'), findsOneWidget);
  });

  testWidgets('CustomerDebtSummaryCard displays Sem Débitos when debt is zero and hides Abater Dívida', (tester) async {
    const summary = CustomerSummaryEntity(
      customerId: 'c1',
      totalPurchasesCount: 2,
      totalDebt: 100.0,
      totalPaid: 100.0,
      currentDebt: 0.0,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomerDebtSummaryCard(
            customer: testCustomer,
            summary: summary,
            debtsViewModel: debtsViewModel,
            authViewModel: authViewModel,
          ),
        ),
      ),
    );

    expect(find.text('Sem Débitos'), findsOneWidget);
    expect(find.text('R\$ 0,00'), findsOneWidget);
    expect(find.text('Abater Dívida'), findsNothing);
  });
}
