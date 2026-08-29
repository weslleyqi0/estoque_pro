import 'package:equatable/equatable.dart';
import 'package:estoque_pro/app/features/customers/domain/entities/customer_payment_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/payment_method.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_item_entity.dart';

enum CustomerStatementType {
  purchase, // Compra a fiado (Débito)
  payment,  // Pagamento / Amortização (Crédito)
}

class CustomerStatementItemEntity extends Equatable {
  final String id;
  final CustomerStatementType type;
  final DateTime date;
  final double amount;
  final String registeredByName;
  final String description;
  final List<SaleItemEntity> items;
  final PaymentMethod? paymentMethod;
  final String notes;
  final String? saleId;
  final String? saleNumber;
  final bool isCancelled;
  final CustomerPaymentEntity? payment;
  final double previousDebt;
  final double newDebt;
  final String? cancellationReason;

  const CustomerStatementItemEntity({
    required this.id,
    required this.type,
    required this.date,
    required this.amount,
    required this.registeredByName,
    required this.description,
    this.items = const [],
    this.paymentMethod,
    this.notes = '',
    this.saleId,
    this.saleNumber,
    this.isCancelled = false,
    this.payment,
    this.previousDebt = 0.0,
    this.newDebt = 0.0,
    this.cancellationReason,
  });

  bool get isPurchase => type == CustomerStatementType.purchase;
  bool get isPayment => type == CustomerStatementType.payment;

  CustomerStatementItemEntity copyWith({
    String? id,
    CustomerStatementType? type,
    DateTime? date,
    double? amount,
    String? registeredByName,
    String? description,
    List<SaleItemEntity>? items,
    PaymentMethod? paymentMethod,
    String? notes,
    String? saleId,
    String? saleNumber,
    bool? isCancelled,
    CustomerPaymentEntity? payment,
    double? previousDebt,
    double? newDebt,
    String? cancellationReason,
  }) {
    return CustomerStatementItemEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      registeredByName: registeredByName ?? this.registeredByName,
      description: description ?? this.description,
      items: items ?? this.items,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      notes: notes ?? this.notes,
      saleId: saleId ?? this.saleId,
      saleNumber: saleNumber ?? this.saleNumber,
      isCancelled: isCancelled ?? this.isCancelled,
      payment: payment ?? this.payment,
      previousDebt: previousDebt ?? this.previousDebt,
      newDebt: newDebt ?? this.newDebt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
    );
  }

  @override
  List<Object?> get props => [
        id,
        type,
        date,
        amount,
        registeredByName,
        description,
        items,
        paymentMethod,
        notes,
        saleId,
        saleNumber,
        isCancelled,
        payment,
        previousDebt,
        newDebt,
        cancellationReason,
      ];
}
