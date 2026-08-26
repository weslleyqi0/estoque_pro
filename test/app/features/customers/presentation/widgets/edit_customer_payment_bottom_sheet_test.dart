import 'package:estoque_pro/app/features/customers/domain/entities/customer_payment_entity.dart';
import 'package:estoque_pro/app/features/customers/domain/repositories/customer_payments_repository.dart';
import 'package:estoque_pro/app/features/customers/presentation/viewmodels/customer_debts_viewmodel.dart';
import 'package:estoque_pro/app/features/customers/presentation/widgets/edit_customer_payment_bottom_sheet.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/payment_method.dart';
import 'package:estoque_pro/app/features/sales/domain/repositories/sales_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSalesRepository extends Mock implements SalesRepository {}
class MockCustomerPaymentsRepository extends Mock implements CustomerPaymentsRepository {}

void main() {
  late MockSalesRepository mockSalesRepo;
  late MockCustomerPaymentsRepository mockPaymentsRepo;
  late CustomerDebtsViewModel debtsViewModel;

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

    when(() => mockSalesRepo.watchAll()).thenAnswer((_) => const Stream.empty());
    when(() => mockPaymentsRepo.watchAll()).thenAnswer((_) => const Stream.empty());
    when(() => mockPaymentsRepo.save(any())).thenAnswer((_) async {});

    debtsViewModel = CustomerDebtsViewModel(mockSalesRepo, mockPaymentsRepo);
  });

  testWidgets('EditCustomerPaymentBottomSheet updates amount and saves', (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final payment = CustomerPaymentEntity(
      id: 'pay_1',
      customerId: 'cust_1',
      customerName: 'João Silva',
      amount: 50.0,
      paymentMethod: PaymentMethod.dinheiro,
      notes: 'Pagamento inicial',
      userId: 'u1',
      userName: 'Operador',
      createdAt: DateTime(2026, 8, 26, 10, 0),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EditCustomerPaymentBottomSheet(
            payment: payment,
            debtsViewModel: debtsViewModel,
            customerName: 'João Silva',
          ),
        ),
      ),
    );

    expect(find.text('Editar Pagamento'), findsOneWidget);
    expect(find.text('50,00'), findsOneWidget);

    final saveButton = find.text('Salvar Alterações');
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    verify(() => mockPaymentsRepo.save(any())).called(1);
  });

  testWidgets('EditCustomerPaymentBottomSheet cancels payment when confirmed', (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final payment = CustomerPaymentEntity(
      id: 'pay_1',
      customerId: 'cust_1',
      customerName: 'João Silva',
      amount: 50.0,
      paymentMethod: PaymentMethod.dinheiro,
      notes: 'Pagamento inicial',
      userId: 'u1',
      userName: 'Operador',
      createdAt: DateTime(2026, 8, 26, 10, 0),
    );

    when(() => mockPaymentsRepo.watchAll()).thenAnswer((_) => Stream.value([payment]));
    debtsViewModel.listenAll();
    await tester.pump(const Duration(milliseconds: 50));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EditCustomerPaymentBottomSheet(
            payment: payment,
            debtsViewModel: debtsViewModel,
            customerName: 'João Silva',
          ),
        ),
      ),
    );

    final cancelButton = find.text('Cancelar Pagamento');
    await tester.ensureVisible(cancelButton);
    await tester.tap(cancelButton);
    await tester.pumpAndSettle();

    expect(find.text('Cancelar Pagamento?'), findsOneWidget);
    expect(find.text('Motivo do Cancelamento *'), findsOneWidget);

    // Tenta confirmar sem motivo (validação bloqueia)
    await tester.tap(find.text('Confirmar Cancelamento'));
    await tester.pumpAndSettle();
    expect(find.text('Informe o motivo do cancelamento.'), findsOneWidget);

    // Digita o motivo
    await tester.enterText(find.byType(TextField).last, 'Estorno solicitado pelo cliente');
    await tester.pumpAndSettle();

    // Confirma cancelamento
    await tester.tap(find.text('Confirmar Cancelamento'));
    await tester.pumpAndSettle();

    final captured = verify(() => mockPaymentsRepo.save(captureAny())).captured;
    expect(captured.isNotEmpty, isTrue);
    final saved = captured.last as CustomerPaymentEntity;
    expect(saved.isCancelled, isTrue);
    expect(saved.cancellationReason, 'Estorno solicitado pelo cliente');
  });
}
