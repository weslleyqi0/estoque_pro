import 'package:estoque_pro/app/features/customers/domain/entities/customer_payment_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/payment_method.dart';

class CustomerPaymentModel {
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

  const CustomerPaymentModel({
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

  factory CustomerPaymentModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return CustomerPaymentModel(
      id: id,
      customerId: map['customer_id'] as String? ?? '',
      customerName: map['customer_name'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: PaymentMethod.fromValue(map['payment_method'] as String?) ?? PaymentMethod.dinheiro,
      notes: map['notes'] as String? ?? '',
      userId: map['user_id'] as String? ?? '',
      userName: map['user_name'] as String? ?? '',
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      isCancelled: map['is_cancelled'] as bool? ?? false,
      cancelledAt: map['cancelled_at'] != null
          ? DateTime.tryParse(map['cancelled_at'] as String)
          : null,
      cancellationReason: map['cancellation_reason'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customer_id': customerId,
      'customer_name': customerName,
      'amount': amount,
      'payment_method': paymentMethod.value,
      'notes': notes,
      'user_id': userId,
      'user_name': userName,
      'created_at': createdAt.toIso8601String(),
      'is_cancelled': isCancelled,
      if (cancelledAt != null) 'cancelled_at': cancelledAt!.toIso8601String(),
      if (cancellationReason != null) 'cancellation_reason': cancellationReason,
    };
  }

  CustomerPaymentEntity toEntity() {
    return CustomerPaymentEntity(
      id: id,
      customerId: customerId,
      customerName: customerName,
      amount: amount,
      paymentMethod: paymentMethod,
      notes: notes,
      userId: userId,
      userName: userName,
      createdAt: createdAt,
      isCancelled: isCancelled,
      cancelledAt: cancelledAt,
      cancellationReason: cancellationReason,
    );
  }

  factory CustomerPaymentModel.fromEntity(CustomerPaymentEntity entity) {
    return CustomerPaymentModel(
      id: entity.id,
      customerId: entity.customerId,
      customerName: entity.customerName,
      amount: entity.amount,
      paymentMethod: entity.paymentMethod,
      notes: entity.notes,
      userId: entity.userId,
      userName: entity.userName,
      createdAt: entity.createdAt,
      isCancelled: entity.isCancelled,
      cancelledAt: entity.cancelledAt,
      cancellationReason: entity.cancellationReason,
    );
  }
}
