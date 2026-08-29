import 'package:equatable/equatable.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/payment_method.dart';

class CustomerPaymentEntity extends Equatable {
  final String id;
  final String customerId;
  final String customerName;
  final double amount;
  final PaymentMethod paymentMethod;
  final String notes;
  final String userId;
  final String userName;
  final DateTime createdAt;
  final bool isCancelled;
  final DateTime? cancelledAt;
  final String? cancellationReason;

  const CustomerPaymentEntity({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.amount,
    required this.paymentMethod,
    this.notes = '',
    required this.userId,
    required this.userName,
    required this.createdAt,
    this.isCancelled = false,
    this.cancelledAt,
    this.cancellationReason,
  });

  CustomerPaymentEntity copyWith({
    String? id,
    String? customerId,
    String? customerName,
    double? amount,
    PaymentMethod? paymentMethod,
    String? notes,
    String? userId,
    String? userName,
    DateTime? createdAt,
    bool? isCancelled,
    DateTime? cancelledAt,
    String? cancellationReason,
  }) {
    return CustomerPaymentEntity(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      notes: notes ?? this.notes,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      createdAt: createdAt ?? this.createdAt,
      isCancelled: isCancelled ?? this.isCancelled,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
    );
  }

  @override
  List<Object?> get props => [
        id,
        customerId,
        customerName,
        amount,
        paymentMethod,
        notes,
        userId,
        userName,
        createdAt,
        isCancelled,
        cancelledAt,
        cancellationReason,
      ];
}
