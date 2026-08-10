import 'package:estoque_pro/app/core/utils/date_parser.dart';
import 'package:estoque_pro/app/features/sales/data/models/sale_item_model.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/discount_type.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/payment_method.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_status.dart';
import 'package:firebase_database/firebase_database.dart';

class SaleModel {
  final String id;
  final String saleNumber;
  final List<SaleItemModel> items;
  final double subtotal;
  final String discountType;
  final double discountValue;
  final double total;
  final String paymentMethod;
  final double? amountPaid;
  final double? change;
  final String? customerId;
  final String? customerName;
  final String userId;
  final String userName;
  final String status;
  final String observations;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const SaleModel({
    required this.id,
    required this.saleNumber,
    required this.items,
    required this.subtotal,
    required this.discountType,
    required this.discountValue,
    required this.total,
    required this.paymentMethod,
    this.amountPaid,
    this.change,
    this.customerId,
    this.customerName,
    required this.userId,
    required this.userName,
    required this.status,
    required this.observations,
    required this.createdAt,
    this.updatedAt,
  });

  factory SaleModel.fromMap(String id, Map<dynamic, dynamic> map) {
    final rawItems = map['items'] as List<dynamic>? ?? [];
    return SaleModel(
      id: id,
      saleNumber: map['sale_number'] as String? ?? '',
      items: rawItems
          .map((e) => SaleItemModel.fromMap(Map<dynamic, dynamic>.from(e as Map)))
          .toList(),
      subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0.0,
      discountType: map['discount_type'] as String? ?? 'value',
      discountValue: (map['discount_value'] as num?)?.toDouble() ?? 0.0,
      total: (map['total'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: map['payment_method'] as String? ?? 'dinheiro',
      amountPaid: (map['amount_paid'] as num?)?.toDouble(),
      change: (map['change'] as num?)?.toDouble(),
      customerId: map['customer_id'] as String?,
      customerName: map['customer_name'] as String?,
      userId: map['user_id'] as String? ?? '',
      userName: map['user_name'] as String? ?? '',
      status: map['status'] as String? ?? 'completed',
      observations: map['observations'] as String? ?? '',
      createdAt: DateParser.parse(map['created_at']) ?? DateTime.now(),
      updatedAt: DateParser.parse(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sale_number': saleNumber,
      'items': items.map((e) => e.toMap()).toList(),
      'subtotal': subtotal,
      'discount_type': discountType,
      'discount_value': discountValue,
      'total': total,
      'payment_method': paymentMethod,
      if (amountPaid != null) 'amount_paid': amountPaid,
      if (change != null) 'change': change,
      if (customerId != null) 'customer_id': customerId,
      if (customerName != null) 'customer_name': customerName,
      'user_id': userId,
      'user_name': userName,
      'status': status,
      'observations': observations,
      'created_at': createdAt.toIso8601String(),
      'updated_at': ServerValue.timestamp,
    };
  }

  SaleEntity toEntity() {
    return SaleEntity(
      id: id,
      saleNumber: saleNumber,
      items: items.map((e) => e.toEntity()).toList(),
      subtotal: subtotal,
      discountType: DiscountType.fromValue(discountType),
      discountValue: discountValue,
      total: total,
      paymentMethod: PaymentMethod.fromValue(paymentMethod) ?? PaymentMethod.dinheiro,
      amountPaid: amountPaid,
      change: change,
      customerId: customerId,
      customerName: customerName,
      userId: userId,
      userName: userName,
      status: SaleStatus.fromValue(status),
      observations: observations,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory SaleModel.fromEntity(SaleEntity entity) {
    return SaleModel(
      id: entity.id,
      saleNumber: entity.saleNumber,
      items: entity.items.map((e) => SaleItemModel.fromEntity(e)).toList(),
      subtotal: entity.subtotal,
      discountType: entity.discountType.rawValue,
      discountValue: entity.discountValue,
      total: entity.total,
      paymentMethod: entity.paymentMethod.value,
      amountPaid: entity.amountPaid,
      change: entity.change,
      customerId: entity.customerId,
      customerName: entity.customerName,
      userId: entity.userId,
      userName: entity.userName,
      status: entity.status.value,
      observations: entity.observations,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
