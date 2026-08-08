import 'package:equatable/equatable.dart';

class SaleItemEntity extends Equatable {
  final String productId;
  final String productName;
  final String productImgUrl;
  final double unitPrice;
  final int quantity;

  double get totalPrice => unitPrice * quantity;

  const SaleItemEntity({
    required this.productId,
    required this.productName,
    required this.productImgUrl,
    required this.unitPrice,
    required this.quantity,
  });

  SaleItemEntity copyWith({
    String? productId,
    String? productName,
    String? productImgUrl,
    double? unitPrice,
    int? quantity,
  }) {
    return SaleItemEntity(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productImgUrl: productImgUrl ?? this.productImgUrl,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  List<Object?> get props => [
        productId,
        productName,
        productImgUrl,
        unitPrice,
        quantity,
      ];
}
