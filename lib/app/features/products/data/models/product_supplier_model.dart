import 'package:estoque_pro/app/features/products/domain/entities/product_supplier_entity.dart';

class ProductSupplierModel {
  final String id;
  final String name;

  const ProductSupplierModel({
    required this.id,
    required this.name,
  });

  factory ProductSupplierModel.fromMap(Map<dynamic, dynamic> map) {
    return ProductSupplierModel(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  ProductSupplierEntity toEntity() {
    return ProductSupplierEntity(
      id: id,
      name: name,
    );
  }

  factory ProductSupplierModel.fromEntity(ProductSupplierEntity entity) {
    return ProductSupplierModel(
      id: entity.id,
      name: entity.name,
    );
  }
}
