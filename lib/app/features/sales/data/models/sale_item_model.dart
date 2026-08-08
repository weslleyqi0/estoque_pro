import 'package:estoque_pro/app/features/sales/domain/entities/sale_item_entity.dart';

class SaleItemModel {
  final String productId;
  final String productName;
  final String productImgUrl;
  final double unitPrice;
  final int quantity;

  const SaleItemModel({
    required this.productId,
    required this.productName,
    required this.productImgUrl,
    required this.unitPrice,
    required this.quantity,
  });

  factory SaleItemModel.fromMap(Map<dynamic, dynamic> map) {
    return SaleItemModel(
      productId: map['product_id'] as String? ?? '',
      productName: map['product_name'] as String? ?? '',
      productImgUrl: map['product_img_url'] as String? ?? '',
      unitPrice: (map['unit_price'] as num?)?.toDouble() ?? 0.0,
      quantity: map['quantity'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'product_id': productId,
      'product_name': productName,
      'product_img_url': productImgUrl,
      'unit_price': unitPrice,
      'quantity': quantity,
    };
  }

  SaleItemEntity toEntity() {
    return SaleItemEntity(
      productId: productId,
      productName: productName,
      productImgUrl: productImgUrl,
      unitPrice: unitPrice,
      quantity: quantity,
    );
  }

  factory SaleItemModel.fromEntity(SaleItemEntity entity) {
    return SaleItemModel(
      productId: entity.productId,
      productName: entity.productName,
      productImgUrl: entity.productImgUrl,
      unitPrice: entity.unitPrice,
      quantity: entity.quantity,
    );
  }
}
