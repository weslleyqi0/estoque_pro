import 'dart:async';

import 'package:estoque_pro/app/core/base/base_viewmodel.dart';
import 'package:estoque_pro/app/core/utils/command.dart';
import 'package:estoque_pro/app/features/customers/domain/entities/customer_payment_entity.dart';
import 'package:estoque_pro/app/features/customers/domain/entities/customer_statement_item_entity.dart';
import 'package:estoque_pro/app/features/customers/domain/entities/customer_summary_entity.dart';
import 'package:estoque_pro/app/features/customers/domain/usecases/cancel_customer_payment_use_case.dart';
import 'package:estoque_pro/app/features/customers/domain/usecases/get_customer_payments_use_case.dart';
import 'package:estoque_pro/app/features/customers/domain/usecases/register_customer_payment_use_case.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/payment_method.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_status.dart';
import 'package:estoque_pro/app/features/sales/domain/usecases/get_sales_use_case.dart';

class CustomerDebtsViewModel extends BaseViewModel {
  final GetSalesUseCase _getSalesUseCase;
  final GetCustomerPaymentsUseCase _getCustomerPaymentsUseCase;
  final RegisterCustomerPaymentUseCase _registerCustomerPaymentUseCase;
  final CancelCustomerPaymentUseCase _cancelCustomerPaymentUseCase;

  late final Command1<bool, CustomerPaymentEntity> registerPaymentCommand;
  late final Command1<bool, ({CustomerPaymentEntity payment, String reason})> cancelPaymentCommand;

  StreamSubscription<List<SaleEntity>>? _salesSubscription;
  StreamSubscription<List<CustomerPaymentEntity>>? _paymentsSubscription;

  List<SaleEntity> _sales = [];
  List<CustomerPaymentEntity> _payments = [];

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Object? _error;
  Object? get error => _error;

  CustomerDebtsViewModel(
    this._getSalesUseCase,
    this._getCustomerPaymentsUseCase,
    this._registerCustomerPaymentUseCase,
    this._cancelCustomerPaymentUseCase,
  ) {
    registerPaymentCommand = Command1((payment) => _registerCustomerPaymentUseCase(payment));
    cancelPaymentCommand = Command1(
      (params) => _cancelCustomerPaymentUseCase(params.payment, reason: params.reason),
    );
  }

  void listenAll() {
    _isLoading = true;
    notifyListeners();

    _salesSubscription?.cancel();
    _paymentsSubscription?.cancel();

    _salesSubscription = _getSalesUseCase.watchAll().listen(
      (salesList) {
        _sales = salesList;
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        _error = e;
        _isLoading = false;
        notifyListeners();
      },
    );

    _paymentsSubscription = _getCustomerPaymentsUseCase.watchAll().listen(
      (paymentsList) {
        _payments = paymentsList;
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        _error = e;
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// Retorna o resumo consolidado de compras, débitos, pagamentos e saldo devedor do cliente.
  /// Pagamentos cancelados são desconsiderados na soma de pagamentos, fazendo com que o valor retorne para a dívida.
  CustomerSummaryEntity getCustomerSummary(String customerId) {
    if (customerId.trim().isEmpty) {
      return const CustomerSummaryEntity(customerId: '');
    }

    final customerSales = _sales.where(
      (s) => s.customerId == customerId && s.status != SaleStatus.cancelled,
    );

    final totalPurchasesCount = customerSales.length;

    final totalDebt = customerSales
        .where((s) => s.paymentMethod == PaymentMethod.fiado)
        .fold(0.0, (sum, s) => sum + s.total);

    final totalPaid = _payments
        .where((p) => p.customerId == customerId && !p.isCancelled)
        .fold(0.0, (sum, p) => sum + p.amount);

    final currentDebt = (totalDebt - totalPaid) > 0.001 ? (totalDebt - totalPaid) : 0.0;

    return CustomerSummaryEntity(
      customerId: customerId,
      totalPurchasesCount: totalPurchasesCount,
      totalDebt: totalDebt,
      totalPaid: totalPaid,
      currentDebt: currentDebt,
    );
  }

  /// Retorna o extrato unificado de compras e pagamentos do cliente em ordem decrescente de data.
  List<CustomerStatementItemEntity> getCustomerStatement(String customerId) {
    if (customerId.trim().isEmpty) return [];

    final List<CustomerStatementItemEntity> statement = [];

    // Compras a fiado não canceladas
    final customerSales = _sales.where(
      (s) =>
          s.customerId == customerId &&
          s.paymentMethod == PaymentMethod.fiado &&
          s.status != SaleStatus.cancelled,
    );

    for (final sale in customerSales) {
      statement.add(
        CustomerStatementItemEntity(
          id: sale.id,
          type: CustomerStatementType.purchase,
          date: sale.createdAt,
          amount: sale.total,
          registeredByName: sale.userName,
          description: 'Compra #${sale.saleNumber}',
          items: sale.items,
          paymentMethod: sale.paymentMethod,
          notes: sale.observations,
          saleId: sale.id,
          saleNumber: sale.saleNumber,
          isCancelled: false,
        ),
      );
    }

    // Pagamentos (ativos ou cancelados)
    final customerPayments = _payments.where((p) => p.customerId == customerId);
    for (final payment in customerPayments) {
      statement.add(
        CustomerStatementItemEntity(
          id: payment.id,
          type: CustomerStatementType.payment,
          date: payment.createdAt,
          amount: payment.amount,
          registeredByName: payment.userName,
          description: 'Pagamento recebido',
          paymentMethod: payment.paymentMethod,
          notes: payment.notes,
          isCancelled: payment.isCancelled,
          payment: payment,
          cancellationReason: payment.cancellationReason,
        ),
      );
    }

    // Ordenar cronologicamente em ordem crescente para calcular saldos parciais acumulados
    statement.sort((a, b) => a.date.compareTo(b.date));

    double runningDebt = 0.0;
    final List<CustomerStatementItemEntity> calculatedStatement = [];

    for (final item in statement) {
      final double previousDebt = runningDebt;
      if (item.type == CustomerStatementType.purchase) {
        runningDebt += item.amount;
      } else if (item.type == CustomerStatementType.payment && !item.isCancelled) {
        runningDebt = (runningDebt - item.amount) > 0.001 ? (runningDebt - item.amount) : 0.0;
      }

      calculatedStatement.add(
        item.copyWith(
          previousDebt: previousDebt,
          newDebt: runningDebt,
        ),
      );
    }

    // Inverter para apresentar do mais recente para o mais antigo na UI
    calculatedStatement.sort((a, b) => b.date.compareTo(a.date));

    return calculatedStatement;
  }

  /// Retorna a entidade de venda correspondente pelo ID caso disponível.
  SaleEntity? getSaleById(String? saleId) {
    if (saleId == null || saleId.isEmpty) return null;
    final matches = _sales.where((s) => s.id == saleId);
    return matches.isNotEmpty ? matches.first : null;
  }



  @override
  void dispose() {
    _salesSubscription?.cancel();
    _paymentsSubscription?.cancel();
    super.dispose();
  }
}
