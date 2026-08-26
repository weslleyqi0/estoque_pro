import 'package:equatable/equatable.dart';
import 'package:estoque_pro/app/features/deliveries/domain/entities/delivery_status.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/payment_method.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_item_entity.dart';

class DeliveryEntity extends Equatable {
  final String id;
  final String saleId;
  final String saleNumber;
  final String customerId;
  final String customerName;
  final String? customerPhone;
  final String customerAddress;
  final List<SaleItemEntity> items;
  final double subtotal;
  final double totalAmount;
  final PaymentMethod paymentMethod;
  final DeliveryStatus status;
  final DateTime scheduledAt;
  final DateTime? deliveredAt;
  final String observations;
  final String userId;
  final String userName;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const DeliveryEntity({
    required this.id,
    required this.saleId,
    required this.saleNumber,
    required this.customerId,
    required this.customerName,
    this.customerPhone,
    required this.customerAddress,
    required this.items,
    required this.subtotal,
    required this.totalAmount,
    required this.paymentMethod,
    this.status = DeliveryStatus.pending,
    required this.scheduledAt,
    this.deliveredAt,
    this.observations = '',
    required this.userId,
    required this.userName,
    required this.createdAt,
    this.updatedAt,
  });

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  /// Check if the delivery is delayed (scheduled date/time is in the past and delivery is not completed or cancelled)
  bool get isDelayed {
    if (status == DeliveryStatus.completed || status == DeliveryStatus.cancelled) {
      return false;
    }
    if (status == DeliveryStatus.delayed) {
      return true;
    }
    return scheduledAt.isBefore(DateTime.now());
  }

  /// Returns the effective status, which evaluates to [DeliveryStatus.delayed] if overdue
  DeliveryStatus get effectiveStatus {
    if (status == DeliveryStatus.completed || status == DeliveryStatus.cancelled) {
      return status;
    }
    if (isDelayed) {
      return DeliveryStatus.delayed;
    }
    return status;
  }

  DeliveryEntity copyWith({
    String? id,
    String? saleId,
    String? saleNumber,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? customerAddress,
    List<SaleItemEntity>? items,
    double? subtotal,
    double? totalAmount,
    PaymentMethod? paymentMethod,
    DeliveryStatus? status,
    DateTime? scheduledAt,
    DateTime? deliveredAt,
    String? observations,
    String? userId,
    String? userName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DeliveryEntity(
      id: id ?? this.id,
      saleId: saleId ?? this.saleId,
      saleNumber: saleNumber ?? this.saleNumber,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerAddress: customerAddress ?? this.customerAddress,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      observations: observations ?? this.observations,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        saleId,
        saleNumber,
        customerId,
        customerName,
        customerPhone,
        customerAddress,
        items,
        subtotal,
        totalAmount,
        paymentMethod,
        status,
        scheduledAt,
        deliveredAt,
        observations,
        userId,
        userName,
        createdAt,
        updatedAt,
      ];
}
