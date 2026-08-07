import 'package:equatable/equatable.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_category_entity.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_supplier_entity.dart';

class ProductEntity extends Equatable {
  final String id;
  final String name;
  final String imgUrl;
  final String description;
  final String barcode;
  final List<ProductCategoryEntity> categories;
  final ProductSupplierEntity? supplier;
  final double price;
  final int stock;
  final int minStock;
  final bool isActive;
  final DateTime? updatedAt;

  const ProductEntity({
    required this.id,
    required this.name,
    required this.imgUrl,
    required this.description,
    this.barcode = '',
    required this.categories,
    this.supplier,
    required this.price,
    required this.stock,
    required this.minStock,
    this.isActive = true,
    this.updatedAt,
  });

  ProductEntity copyWith({
    String? id,
    String? name,
    String? imgUrl,
    String? description,
    String? barcode,
    List<ProductCategoryEntity>? categories,
    ProductSupplierEntity? supplier,
    double? price,
    int? stock,
    int? minStock,
    bool? isActive,
    DateTime? updatedAt,
  }) {
    return ProductEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      imgUrl: imgUrl ?? this.imgUrl,
      description: description ?? this.description,
      barcode: barcode ?? this.barcode,
      categories: categories ?? this.categories,
      supplier: supplier ?? this.supplier,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      minStock: minStock ?? this.minStock,
      isActive: isActive ?? this.isActive,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    imgUrl,
    description,
    barcode,
    categories,
    supplier,
    price,
    stock,
    minStock,
    isActive,
    updatedAt,
  ];
}
