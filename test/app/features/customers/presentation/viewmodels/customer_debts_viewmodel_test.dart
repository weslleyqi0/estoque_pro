import 'package:estoque_pro/app/core/errors/app_failure.dart';
import 'package:estoque_pro/app/features/customers/domain/entities/customer_payment_entity.dart';
import 'package:estoque_pro/app/features/customers/domain/entities/customer_statement_item_entity.dart';
import 'package:estoque_pro/app/features/customers/domain/repositories/customer_payments_repository.dart';
import 'package:estoque_pro/app/features/customers/domain/usecases/cancel_customer_payment_use_case.dart';
import 'package:estoque_pro/app/features/customers/domain/usecases/get_customer_payments_use_case.dart';
import 'package:estoque_pro/app/features/customers/domain/usecases/register_customer_payment_use_case.dart';
import 'package:estoque_pro/app/features/customers/presentation/viewmodels/customer_debts_viewmodel.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/payment_method.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_item_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_status.dart';
import 'package:estoque_pro/app/features/sales/domain/repositories/sales_repository.dart';
import 'package:estoque_pro/app/features/sales/domain/usecases/get_sales_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSalesRepository extends Mock implements SalesRepository {}
class MockCustomerPaymentsRepository extends Mock implements CustomerPaymentsRepository {}

void main() {
  late MockSalesRepository mockSalesRepo;
  late MockCustomerPaymentsRepository mockPaymentsRepo;
  late CustomerDebtsViewModel viewModel;

  CustomerDebtsViewModel createViewModel() {
    return CustomerDebtsViewModel(
      GetSalesUseCase(mockSalesRepo),
      GetCustomerPaymentsUseCase(mockPaymentsRepo),
      RegisterCustomerPaymentUseCase(mockPaymentsRepo),
      CancelCustomerPaymentUseCase(mockPaymentsRepo),
    );
  }

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
  });

  test('getCustomerSummary computes total purchases, fiado debt, paid amount and remaining debt', () async {
    final sale1 = SaleEntity(
      id: 's1',
      saleNumber: 'VENDA-001',
      items: const [
        SaleItemEntity(
          productId: 'p1',
          productName: 'Item A',
          productImgUrl: '',
          quantity: 2,
          unitPrice: 50.0,
        ),
      ],
      subtotal: 100.0,
      total: 100.0,
      paymentMethod: PaymentMethod.fiado,
      customerId: 'cust_1',
      customerName: 'João Silva',
      userId: 'u1',
      userName: 'Vendedor 1',
      status: SaleStatus.completed,
      createdAt: DateTime(2026, 8, 20, 10, 0),
    );

    final sale2 = SaleEntity(
      id: 's2',
      saleNumber: 'VENDA-002',
      items: const [
        SaleItemEntity(
          productId: 'p2',
          productName: 'Item B',
          productImgUrl: '',
          quantity: 1,
          unitPrice: 50.0,
        ),
      ],
      subtotal: 50.0,
      total: 50.0,
      paymentMethod: PaymentMethod.pix, // Not fiado
      customerId: 'cust_1',
      customerName: 'João Silva',
      userId: 'u1',
      userName: 'Vendedor 1',
      status: SaleStatus.completed,
      createdAt: DateTime(2026, 8, 21, 10, 0),
    );

    final payment1 = CustomerPaymentEntity(
      id: 'pay_1',
      customerId: 'cust_1',
      customerName: 'João Silva',
      amount: 40.0,
      paymentMethod: PaymentMethod.pix,
      userId: 'u2',
      userName: 'Caixa 2',
      createdAt: DateTime(2026, 8, 22, 14, 0),
    );

    when(() => mockSalesRepo.watchAll()).thenAnswer((_) => Stream.value([sale1, sale2]));
    when(() => mockPaymentsRepo.watchAll()).thenAnswer((_) => Stream.value([payment1]));

    viewModel = createViewModel();
    viewModel.listenAll();

    await Future<void>.delayed(const Duration(milliseconds: 50));

    final summary = viewModel.getCustomerSummary('cust_1');
    expect(summary.totalPurchasesCount, 2);
    expect(summary.totalDebt, 100.0);
    expect(summary.totalPaid, 40.0);
    expect(summary.currentDebt, 60.0);
    expect(summary.hasPendingDebt, isTrue);
  });

  test('cancelled payments are excluded from totalPaid in getCustomerSummary', () async {
    final sale1 = SaleEntity(
      id: 's1',
      saleNumber: 'VENDA-001',
      items: const [],
      subtotal: 100.0,
      total: 100.0,
      paymentMethod: PaymentMethod.fiado,
      customerId: 'cust_1',
      customerName: 'João Silva',
      userId: 'u1',
      userName: 'Vendedor 1',
      status: SaleStatus.completed,
      createdAt: DateTime(2026, 8, 20, 10, 0),
    );

    final payment1 = CustomerPaymentEntity(
      id: 'pay_1',
      customerId: 'cust_1',
      customerName: 'João Silva',
      amount: 40.0,
      paymentMethod: PaymentMethod.pix,
      userId: 'u2',
      userName: 'Caixa 2',
      createdAt: DateTime(2026, 8, 22, 14, 0),
      isCancelled: true,
    );

    when(() => mockSalesRepo.watchAll()).thenAnswer((_) => Stream.value([sale1]));
    when(() => mockPaymentsRepo.watchAll()).thenAnswer((_) => Stream.value([payment1]));

    viewModel = createViewModel();
    viewModel.listenAll();

    await Future<void>.delayed(const Duration(milliseconds: 50));

    final summary = viewModel.getCustomerSummary('cust_1');
    expect(summary.totalDebt, 100.0);
    expect(summary.totalPaid, 0.0);
    expect(summary.currentDebt, 100.0);
  });

  test('getCustomerStatement unifies fiado sales and payments ordered by date descending', () async {
    final sale1 = SaleEntity(
      id: 's1',
      saleNumber: 'VENDA-001',
      items: const [
        SaleItemEntity(
          productId: 'p1',
          productName: 'Coca Cola',
          productImgUrl: '',
          quantity: 2,
          unitPrice: 10.0,
        ),
      ],
      subtotal: 20.0,
      total: 20.0,
      paymentMethod: PaymentMethod.fiado,
      customerId: 'cust_1',
      customerName: 'João Silva',
      userId: 'u1',
      userName: 'Carlos Vendedor',
      status: SaleStatus.completed,
      createdAt: DateTime(2026, 8, 20, 10, 0),
    );

    final payment1 = CustomerPaymentEntity(
      id: 'pay_1',
      customerId: 'cust_1',
      customerName: 'João Silva',
      amount: 20.0,
      paymentMethod: PaymentMethod.dinheiro,
      notes: 'Quitação total',
      userId: 'u2',
      userName: 'Ana Caixa',
      createdAt: DateTime(2026, 8, 22, 16, 0),
    );

    when(() => mockSalesRepo.watchAll()).thenAnswer((_) => Stream.value([sale1]));
    when(() => mockPaymentsRepo.watchAll()).thenAnswer((_) => Stream.value([payment1]));

    viewModel = createViewModel();
    viewModel.listenAll();

    await Future<void>.delayed(const Duration(milliseconds: 50));

    final statement = viewModel.getCustomerStatement('cust_1');
    expect(statement.length, 2);

    // O mais recente deve ser o pagamento (20.0 -> 0.0)
    expect(statement[0].type, CustomerStatementType.payment);
    expect(statement[0].amount, 20.0);
    expect(statement[0].previousDebt, 20.0);
    expect(statement[0].newDebt, 0.0);
    expect(statement[0].registeredByName, 'Ana Caixa');
    expect(statement[0].notes, 'Quitação total');

    // O segundo é a compra (0.0 -> 20.0)
    expect(statement[1].type, CustomerStatementType.purchase);
    expect(statement[1].amount, 20.0);
    expect(statement[1].previousDebt, 0.0);
    expect(statement[1].newDebt, 20.0);
    expect(statement[1].registeredByName, 'Carlos Vendedor');
    expect(statement[1].items.first.productName, 'Coca Cola');
  });

  test('registerPayment saves entity via repository', () async {
    when(() => mockSalesRepo.watchAll()).thenAnswer((_) => const Stream.empty());
    when(() => mockPaymentsRepo.watchAll()).thenAnswer((_) => const Stream.empty());
    when(() => mockPaymentsRepo.save(any())).thenAnswer((_) async {});

    viewModel = createViewModel();

    await viewModel.registerPayment(
      customerId: 'cust_1',
      customerName: 'João Silva',
      amount: 50.0,
      paymentMethod: PaymentMethod.pix,
      notes: 'Pagamento parcial',
      userId: 'u1',
      userName: 'Operador Teste',
    );

    verify(() => mockPaymentsRepo.save(any())).called(1);
  });

  test('updatePayment updates entity via repository', () async {
    when(() => mockSalesRepo.watchAll()).thenAnswer((_) => const Stream.empty());
    when(() => mockPaymentsRepo.watchAll()).thenAnswer((_) => const Stream.empty());
    when(() => mockPaymentsRepo.save(any())).thenAnswer((_) async {});

    viewModel = createViewModel();

    final payment = CustomerPaymentEntity(
      id: 'pay_1',
      customerId: 'cust_1',
      customerName: 'João Silva',
      amount: 70.0,
      paymentMethod: PaymentMethod.pix,
      userId: 'u1',
      userName: 'Operador',
      createdAt: DateTime.now(),
    );

    await viewModel.updatePayment(payment);

    verify(() => mockPaymentsRepo.save(payment)).called(1);
  });

  test('cancelPayment throws error when reason is empty', () async {
    final payment = CustomerPaymentEntity(
      id: 'pay_1',
      customerId: 'cust_1',
      customerName: 'João Silva',
      amount: 50.0,
      paymentMethod: PaymentMethod.pix,
      userId: 'u1',
      userName: 'Operador',
      createdAt: DateTime.now(),
    );

    when(() => mockSalesRepo.watchAll()).thenAnswer((_) => const Stream.empty());
    when(() => mockPaymentsRepo.watchAll()).thenAnswer((_) => Stream.value([payment]));

    viewModel = createViewModel();
    viewModel.listenAll();
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(
      () => viewModel.cancelPayment('pay_1', reason: '   '),
      throwsA(isA<BusinessRuleFailure>()),
    );
  });

  test('cancelPayment updates payment with isCancelled true and cancellationReason', () async {
    final payment = CustomerPaymentEntity(
      id: 'pay_1',
      customerId: 'cust_1',
      customerName: 'João Silva',
      amount: 50.0,
      paymentMethod: PaymentMethod.pix,
      userId: 'u1',
      userName: 'Operador',
      createdAt: DateTime.now(),
    );

    when(() => mockSalesRepo.watchAll()).thenAnswer((_) => const Stream.empty());
    when(() => mockPaymentsRepo.watchAll()).thenAnswer((_) => Stream.value([payment]));
    when(() => mockPaymentsRepo.save(any())).thenAnswer((_) async {});

    viewModel = createViewModel();
    viewModel.listenAll();

    await Future<void>.delayed(const Duration(milliseconds: 50));

    await viewModel.cancelPayment('pay_1', reason: 'Lançamento duplicado');

    final captured = verify(() => mockPaymentsRepo.save(captureAny())).captured;
    expect(captured.isNotEmpty, isTrue);
    final saved = captured.first as CustomerPaymentEntity;
    expect(saved.id, 'pay_1');
    expect(saved.isCancelled, isTrue);
    expect(saved.cancellationReason, 'Lançamento duplicado');
  });
}
