import 'package:estoque_pro/app/core/utils/date_parser.dart';
import 'package:estoque_pro/app/features/deliveries/domain/entities/delivery_entity.dart';
import 'package:estoque_pro/app/features/deliveries/domain/entities/delivery_status.dart';
import 'package:estoque_pro/app/features/sales/data/models/sale_item_model.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/payment_method.dart';
import 'package:firebase_database/firebase_database.dart';

class DeliveryModel {
  final String id;
  final String saleId;
  final String saleNumber;
  final String customerId;
  final String customerName;
  final String? customerPhone;
  final String customerAddress;
  final List<SaleItemModel> items;
  final double subtotal;
  final double totalAmount;
  final String paymentMethod;
  final String status;
  final DateTime scheduledAt;
  final DateTime? deliveredAt;
  final String observations;
  final String userId;
  final String userName;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const DeliveryModel({
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
    required this.status,
    required this.scheduledAt,
    this.deliveredAt,
    required this.observations,
    required this.userId,
    required this.userName,
    required this.createdAt,
    this.updatedAt,
  });

  factory DeliveryModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return DeliveryModel(
      id: id,
      saleId: map['sale_id'] as String? ?? '',
      saleNumber: map['sale_number'] as String? ?? '',
      customerId: map['customer_id'] as String? ?? '',
      customerName: map['customer_name'] as String? ?? '',
      customerPhone: map['customer_phone'] as String?,
      customerAddress: map['customer_address'] as String? ?? '',
      items: _parseList(map['items'], SaleItemModel.fromMap),
      subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (map['total_amount'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: map['payment_method'] as String? ?? 'dinheiro',
      status: map['status'] as String? ?? 'pending',
      scheduledAt: DateParser.parse(map['scheduled_at']) ?? DateTime.now(),
      deliveredAt: DateParser.parse(map['delivered_at']),
      observations: map['observations'] as String? ?? '',
      userId: map['user_id'] as String? ?? '',
      userName: map['user_name'] as String? ?? '',
      createdAt: DateParser.parse(map['created_at']) ?? DateTime.now(),
      updatedAt: DateParser.parse(map['updated_at']),
    );
  }

  static List<T> _parseList<T>(dynamic raw, T Function(Map<dynamic, dynamic>) mapper) {
    if (raw == null) return [];
    if (raw is List) {
      return raw
          .where((e) => e != null && e is Map)
          .map((e) => mapper(Map<dynamic, dynamic>.from(e as Map)))
          .toList();
    }
    if (raw is Map) {
      return raw.values
          .where((e) => e != null && e is Map)
          .map((e) => mapper(Map<dynamic, dynamic>.from(e as Map)))
          .toList();
    }
    return [];
  }

  Map<String, dynamic> toMap() {
    return {
      'sale_id': saleId,
      'sale_number': saleNumber,
      'customer_id': customerId,
      'customer_name': customerName,
      if (customerPhone != null) 'customer_phone': customerPhone,
      'customer_address': customerAddress,
      'items': items.map((e) => e.toMap()).toList(),
      'subtotal': subtotal,
      'total_amount': totalAmount,
      'payment_method': paymentMethod,
      'status': status,
      'scheduled_at': scheduledAt.toIso8601String(),
      if (deliveredAt != null) 'delivered_at': deliveredAt!.toIso8601String(),
      'observations': observations,
      'user_id': userId,
      'user_name': userName,
      'created_at': createdAt.toIso8601String(),
      'updated_at': ServerValue.timestamp,
    };
  }

  DeliveryEntity toEntity() {
    return DeliveryEntity(
      id: id,
      saleId: saleId,
      saleNumber: saleNumber,
      customerId: customerId,
      customerName: customerName,
      customerPhone: customerPhone,
      customerAddress: customerAddress,
      items: items.map((e) => e.toEntity()).toList(),
      subtotal: subtotal,
      totalAmount: totalAmount,
      paymentMethod: PaymentMethod.fromValue(paymentMethod) ?? PaymentMethod.dinheiro,
      status: DeliveryStatus.fromValue(status),
      scheduledAt: scheduledAt,
      deliveredAt: deliveredAt,
      observations: observations,
      userId: userId,
      userName: userName,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory DeliveryModel.fromEntity(DeliveryEntity entity) {
    return DeliveryModel(
      id: entity.id,
      saleId: entity.saleId,
      saleNumber: entity.saleNumber,
      customerId: entity.customerId,
      customerName: entity.customerName,
      customerPhone: entity.customerPhone,
      customerAddress: entity.customerAddress,
      items: entity.items.map((e) => SaleItemModel.fromEntity(e)).toList(),
      subtotal: entity.subtotal,
      totalAmount: entity.totalAmount,
      paymentMethod: entity.paymentMethod.value,
      status: entity.status.value,
      scheduledAt: entity.scheduledAt,
      deliveredAt: entity.deliveredAt,
      observations: entity.observations,
      userId: entity.userId,
      userName: entity.userName,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
