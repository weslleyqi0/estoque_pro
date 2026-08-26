import 'dart:async';

import 'package:estoque_pro/app/features/customers/domain/entities/customer_payment_entity.dart';
import 'package:estoque_pro/app/features/customers/domain/entities/customer_statement_item_entity.dart';
import 'package:estoque_pro/app/features/customers/domain/entities/customer_summary_entity.dart';
import 'package:estoque_pro/app/features/customers/domain/repositories/customer_payments_repository.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/payment_method.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_status.dart';
import 'package:estoque_pro/app/features/sales/domain/repositories/sales_repository.dart';
import 'package:flutter/foundation.dart';

class CustomerDebtsViewModel extends ChangeNotifier {
  final SalesRepository _salesRepository;
  final CustomerPaymentsRepository _paymentsRepository;

  StreamSubscription<List<SaleEntity>>? _salesSubscription;
  StreamSubscription<List<CustomerPaymentEntity>>? _paymentsSubscription;

  List<SaleEntity> _sales = [];
  List<CustomerPaymentEntity> _payments = [];

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Object? _error;
  Object? get error => _error;

  CustomerDebtsViewModel(this._salesRepository, this._paymentsRepository);

  void listenAll() {
    _isLoading = true;
    notifyListeners();

    _salesSubscription?.cancel();
    _paymentsSubscription?.cancel();

    _salesSubscription = _salesRepository.watchAll().listen(
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

    _paymentsSubscription = _paymentsRepository.watchAll().listen(
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

    final statement = <CustomerStatementItemEntity>[];

    // 1. Compras a fiado do cliente
    final fiadoSales = _sales.where(
      (s) =>
          s.customerId == customerId &&
          s.paymentMethod == PaymentMethod.fiado &&
          s.status != SaleStatus.cancelled,
    );

    for (final sale in fiadoSales) {
      statement.add(
        CustomerStatementItemEntity(
          id: sale.id,
          type: CustomerStatementType.purchase,
          date: sale.createdAt,
          amount: sale.total,
          registeredByName: sale.userName,
          description: 'Compra Fiado (${sale.saleNumber})',
          items: sale.items,
          saleId: sale.id,
          saleNumber: sale.saleNumber,
        ),
      );
    }

    // 2. Pagamentos registrados para o cliente
    final customerPayments = _payments.where((p) => p.customerId == customerId);
    for (final payment in customerPayments) {
      statement.add(
        CustomerStatementItemEntity(
          id: payment.id,
          type: CustomerStatementType.payment,
          date: payment.createdAt,
          amount: payment.amount,
          registeredByName: payment.userName,
          description: payment.isCancelled ? 'Pagamento Cancelado' : 'Pagamento de Débito',
          paymentMethod: payment.paymentMethod,
          notes: payment.notes,
          isCancelled: payment.isCancelled,
          payment: payment,
          cancellationReason: payment.cancellationReason,
        ),
      );
    }

    // Ordena do mais antigo para o mais recente para calcular os saldos transitórios de dívida
    statement.sort((a, b) => a.date.compareTo(b.date));

    var runningDebt = 0.0;
    final calculatedStatement = <CustomerStatementItemEntity>[];

    for (final item in statement) {
      final prev = runningDebt;
      if (item.isPurchase) {
        runningDebt += item.amount;
        calculatedStatement.add(
          item.copyWith(
            previousDebt: prev,
            newDebt: runningDebt,
          ),
        );
      } else if (item.isPayment) {
        if (item.isCancelled) {
          // Pagamento cancelado: valor estornado volta para a dívida
          // Ex: saldo estava 850, com o cancelamento o valor de 150 retorna para a dívida (850 -> 1000)
          final prevDebt = (runningDebt > 0 && runningDebt >= item.amount)
              ? (runningDebt - item.amount)
              : 0.0;
          calculatedStatement.add(
            item.copyWith(
              previousDebt: prevDebt,
              newDebt: runningDebt,
            ),
          );
        } else {
          runningDebt = (runningDebt - item.amount) > 0.001 ? (runningDebt - item.amount) : 0.0;
          calculatedStatement.add(
            item.copyWith(
              previousDebt: prev,
              newDebt: runningDebt,
            ),
          );
        }
      }
    }

    // Ordena do mais recente para o mais antigo para visualização
    calculatedStatement.sort((a, b) => b.date.compareTo(a.date));
    return calculatedStatement;
  }

  /// Retorna a entidade de venda correspondente pelo ID caso disponível.
  SaleEntity? getSaleById(String? saleId) {
    if (saleId == null || saleId.isEmpty) return null;
    final matches = _sales.where((s) => s.id == saleId);
    return matches.isNotEmpty ? matches.first : null;
  }

  /// Registra o pagamento / quitação de débito de um cliente.
  Future<void> registerPayment({
    required String customerId,
    required String customerName,
    required double amount,
    required PaymentMethod paymentMethod,
    String notes = '',
    required String userId,
    required String userName,
  }) async {
    if (amount <= 0) {
      throw ArgumentError('O valor do pagamento deve ser maior que zero.');
    }

    final payment = CustomerPaymentEntity(
      id: '',
      customerId: customerId,
      customerName: customerName,
      amount: amount,
      paymentMethod: paymentMethod,
      notes: notes.trim(),
      userId: userId,
      userName: userName,
      createdAt: DateTime.now(),
    );

    await _paymentsRepository.save(payment);
  }

  /// Atualiza os dados de um pagamento existente (ex: valor, forma de pagamento, observações).
  Future<void> updatePayment(CustomerPaymentEntity payment) async {
    if (payment.amount <= 0) {
      throw ArgumentError('O valor do pagamento deve ser maior que zero.');
    }
    await _paymentsRepository.save(payment);
  }

  /// Cancela um pagamento existente com motivo obrigatório. O valor retorna automaticamente para a dívida do cliente
  /// e o registro permanece no extrato com status cancelado.
  Future<void> cancelPayment(String paymentId, {required String reason}) async {
    final trimmedReason = reason.trim();
    if (trimmedReason.isEmpty) {
      throw ArgumentError('Informe o motivo ou uma observação para cancelar o pagamento.');
    }

    final matches = _payments.where((p) => p.id == paymentId);
    if (matches.isNotEmpty) {
      final payment = matches.first;
      final updated = payment.copyWith(
        isCancelled: true,
        cancelledAt: DateTime.now(),
        cancellationReason: trimmedReason,
      );
      await _paymentsRepository.save(updated);
    }
  }

  @override
  void dispose() {
    _salesSubscription?.cancel();
    _paymentsSubscription?.cancel();
    super.dispose();
  }
}
