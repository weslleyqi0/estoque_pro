import 'package:estoque_pro/app/features/products/domain/entities/product_category_entity.dart';

class ProductCategoryModel {
  final String id;
  final String name;

  const ProductCategoryModel({
    required this.id,
    required this.name,
  });

  factory ProductCategoryModel.fromMap(Map<dynamic, dynamic> map) {
    return ProductCategoryModel(
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

  ProductCategoryEntity toEntity() {
    return ProductCategoryEntity(
      id: id,
      name: name,
    );
  }

  factory ProductCategoryModel.fromEntity(ProductCategoryEntity entity) {
    return ProductCategoryModel(
      id: entity.id,
      name: entity.name,
    );
  }
}
