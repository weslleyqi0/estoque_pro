import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/features/customers/domain/entities/customer_statement_item_entity.dart';
import 'package:estoque_pro/app/features/customers/domain/repositories/customer_payments_repository.dart';
import 'package:estoque_pro/app/features/customers/domain/usecases/cancel_customer_payment_use_case.dart';
import 'package:estoque_pro/app/features/customers/domain/usecases/get_customer_payments_use_case.dart';
import 'package:estoque_pro/app/features/customers/domain/usecases/register_customer_payment_use_case.dart';
import 'package:estoque_pro/app/features/customers/presentation/viewmodels/customer_debts_viewmodel.dart';
import 'package:estoque_pro/app/features/customers/presentation/widgets/customer_statement_list.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/payment_method.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_item_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/repositories/sales_repository.dart';
import 'package:estoque_pro/app/features/sales/domain/usecases/get_sales_use_case.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSalesRepository extends Mock implements SalesRepository {}
class MockCustomerPaymentsRepository extends Mock implements CustomerPaymentsRepository {}

void main() {
  late MockSalesRepository mockSalesRepo;
  late MockCustomerPaymentsRepository mockPaymentsRepo;
  late CustomerDebtsViewModel debtsViewModel;

  setUp(() {
    mockSalesRepo = MockSalesRepository();
    mockPaymentsRepo = MockCustomerPaymentsRepository();

    when(() => mockSalesRepo.watchAll(limit: any(named: 'limit'))).thenAnswer((_) => const Stream.empty());
    when(() => mockPaymentsRepo.watchAll()).thenAnswer((_) => const Stream.empty());

    debtsViewModel = CustomerDebtsViewModel(
      GetSalesUseCase(mockSalesRepo),
      GetCustomerPaymentsUseCase(mockPaymentsRepo),
      RegisterCustomerPaymentUseCase(mockPaymentsRepo),
      CancelCustomerPaymentUseCase(mockPaymentsRepo),
    );
  });

  testWidgets('CustomerStatementList displays empty state when items list is empty', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CustomerStatementList(statementItems: []),
        ),
      ),
    );

    expect(find.text('Nenhuma movimentação registrada'), findsOneWidget);
    expect(find.text('Compras a fiado e pagamentos aparecerão aqui.'), findsOneWidget);
  });

  testWidgets('CustomerStatementList opens digital invoice directly when tapping purchase card and edit modal when tapping payment', (tester) async {
    final fixedDate = DateTime(2026, 8, 26, 14, 0);

    final statementItems = [
      CustomerStatementItemEntity(
        id: 'pay_1',
        type: CustomerStatementType.payment,
        date: fixedDate,
        amount: 80.0,
        registeredByName: 'Maria Caixa',
        description: 'Pagamento de Débito',
        paymentMethod: PaymentMethod.pix,
        notes: 'PIX via chave CNPJ',
      ),
      CustomerStatementItemEntity(
        id: 'sale_1',
        type: CustomerStatementType.purchase,
        date: fixedDate.subtract(const Duration(days: 1)),
        amount: 150.0,
        registeredByName: 'João Vendedor',
        description: 'Compra Fiado (VENDA-101)',
        items: const [
          SaleItemEntity(
            productId: 'p1',
            productName: 'Arroz 5kg',
            productImgUrl: '',
            quantity: 3,
            unitPrice: 50.0,
          ),
        ],
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: CustomerStatementList(
              statementItems: statementItems,
              customerName: 'Cliente Teste',
              debtsViewModel: debtsViewModel,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Extrato de Movimentações'), findsOneWidget);
    expect(find.text('2 registros'), findsOneWidget);

    // Pagamento
    expect(find.text('Pagamento de Débito'), findsOneWidget);
    expect(find.text('- R\$ 80,00'), findsOneWidget);
    expect(find.textContaining('Por: Maria Caixa'), findsOneWidget);

    // Compra
    expect(find.text('Compra Fiado (VENDA-101)'), findsOneWidget);
    expect(find.text('+ R\$ 150,00'), findsOneWidget);
    expect(find.textContaining('Por: João Vendedor'), findsOneWidget);

    // Não existe mais botão solto de Comprovante na lista
    expect(find.text('Comprovante'), findsNothing);

    // 1. Clica na compra diretamente para abrir o comprovante / nota digital
    await tester.tap(find.text('Compra Fiado (VENDA-101)'));
    await tester.pumpAndSettle();

    expect(find.text('Comprovante de Venda'), findsOneWidget);
    expect(find.text('Arroz 5kg'), findsOneWidget);

    // Fecha o modal de comprovante
    await tester.tap(find.byIcon(AppIcons.close));
    await tester.pumpAndSettle();

    // 2. Clica no pagamento para abrir o modal de edição / cancelamento
    await tester.tap(find.text('Pagamento de Débito'));
    await tester.pumpAndSettle();

    expect(find.text('Editar Pagamento'), findsOneWidget);
    expect(find.text('Salvar Alterações'), findsOneWidget);
    expect(find.text('Cancelar Pagamento'), findsOneWidget);
  });

  testWidgets('CustomerStatementList displays Cancelado badge for cancelled payment', (tester) async {
    final fixedDate = DateTime(2026, 8, 26, 14, 0);

    final statementItems = [
      CustomerStatementItemEntity(
        id: 'pay_cancelled',
        type: CustomerStatementType.payment,
        date: fixedDate,
        amount: 50.0,
        registeredByName: 'Operador',
        description: 'Pagamento Cancelado',
        paymentMethod: PaymentMethod.dinheiro,
        isCancelled: true,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomerStatementList(
            statementItems: statementItems,
            customerName: 'Cliente Teste',
            debtsViewModel: debtsViewModel,
          ),
        ),
      ),
    );

    expect(find.text('Cancelado'), findsOneWidget);
  });

  testWidgets('CustomerStatementList limits items with maxItems and shows Ver todas as movimentações button', (tester) async {
    final fixedDate = DateTime(2026, 8, 26, 14, 0);
    var viewAllClicked = false;

    final statementItems = List.generate(
      5,
      (i) => CustomerStatementItemEntity(
        id: 'sale_$i',
        type: CustomerStatementType.purchase,
        date: fixedDate.subtract(Duration(hours: i)),
        amount: 20.0 * (i + 1),
        registeredByName: 'Operador $i',
        description: 'Compra Fiado #$i',
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: CustomerStatementList(
              statementItems: statementItems,
              customerName: 'Cliente Teste',
              debtsViewModel: debtsViewModel,
              maxItems: 3,
              showViewAll: true,
              onViewAll: () => viewAllClicked = true,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Últimas Movimentações'), findsOneWidget);
    expect(find.text('Ver todas (5)'), findsOneWidget);
    // Deve renderizar apenas os 3 primeiros itens
    expect(find.text('Compra Fiado #0'), findsOneWidget);
    expect(find.text('Compra Fiado #1'), findsOneWidget);
    expect(find.text('Compra Fiado #2'), findsOneWidget);
    expect(find.text('Compra Fiado #3'), findsNothing);

    // Botão Ver todas no header
    await tester.tap(find.text('Ver todas (5)'));
    expect(viewAllClicked, isTrue);
  });
}
