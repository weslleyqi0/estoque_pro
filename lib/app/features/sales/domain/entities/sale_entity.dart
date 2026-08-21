import 'package:equatable/equatable.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/discount_type.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/payment_method.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_edit_history_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_item_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_status.dart';

class SaleEntity extends Equatable {
  final String id;
  final String saleNumber;
  final List<SaleItemEntity> items;
  final double subtotal;
  final DiscountType discountType;
  final double discountValue;
  final double total;
  final PaymentMethod paymentMethod;
  final double? amountPaid;
  final double? change;
  final String? customerId;
  final String? customerName;
  final String userId;
  final String userName;
  final SaleStatus status;
  final String observations;
  final List<SaleEditHistoryEntity> editHistory;
  final DateTime createdAt;
  final DateTime? updatedAt;

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  double get calculatedDiscount {
    if (discountValue <= 0 || subtotal <= 0) return 0.0;
    if (discountType == DiscountType.percent) {
      final calculated = subtotal * (discountValue / 100);
      return calculated > subtotal ? subtotal : calculated;
    }
    return discountValue > subtotal ? subtotal : discountValue;
  }

  String get discountLabel {
    if (discountValue <= 0 || subtotal <= 0) return 'Desconto';
    final double pct = discountType == DiscountType.percent ? discountValue : (calculatedDiscount / subtotal) * 100;
    final pctStr = pct % 1 == 0 ? pct.toInt().toString() : pct.toStringAsFixed(1);
    return 'Desconto ($pctStr%)';
  }

  const SaleEntity({
    required this.id,
    required this.saleNumber,
    required this.items,
    required this.subtotal,
    this.discountType = DiscountType.valueAmount,
    this.discountValue = 0.0,
    required this.total,
    required this.paymentMethod,
    this.amountPaid,
    this.change,
    this.customerId,
    this.customerName,
    required this.userId,
    required this.userName,
    this.status = SaleStatus.completed,
    this.observations = '',
    this.editHistory = const [],
    required this.createdAt,
    this.updatedAt,
  });

  SaleEntity copyWith({
    String? id,
    String? saleNumber,
    List<SaleItemEntity>? items,
    double? subtotal,
    DiscountType? discountType,
    double? discountValue,
    double? total,
    PaymentMethod? paymentMethod,
    double? amountPaid,
    double? change,
    String? customerId,
    String? customerName,
    String? userId,
    String? userName,
    SaleStatus? status,
    String? observations,
    List<SaleEditHistoryEntity>? editHistory,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SaleEntity(
      id: id ?? this.id,
      saleNumber: saleNumber ?? this.saleNumber,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      total: total ?? this.total,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      amountPaid: amountPaid ?? this.amountPaid,
      change: change ?? this.change,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      status: status ?? this.status,
      observations: observations ?? this.observations,
      editHistory: editHistory ?? this.editHistory,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    saleNumber,
    items,
    subtotal,
    discountType,
    discountValue,
    total,
    paymentMethod,
    amountPaid,
    change,
    customerId,
    customerName,
    userId,
    userName,
    status,
    observations,
    editHistory,
    createdAt,
    updatedAt,
  ];
}
