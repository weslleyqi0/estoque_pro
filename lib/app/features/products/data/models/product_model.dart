import 'package:estoque_pro/app/core/utils/date_parser.dart';
import 'package:estoque_pro/app/features/products/data/models/product_category_model.dart';
import 'package:estoque_pro/app/features/products/data/models/product_supplier_model.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_entity.dart';
import 'package:firebase_database/firebase_database.dart';

class ProductModel {
  final String id;
  final String name;
  final String imgUrl;
  final String description;
  final String barcode;
  final List<ProductCategoryModel> categories;
  final ProductSupplierModel? supplier;
  final double price;
  final int stock;
  final int minStock;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProductModel({
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
    this.createdAt,
    this.updatedAt,
  });

  factory ProductModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return ProductModel(
      id: id,
      name: map['name'] as String? ?? '',
      imgUrl: map['imgUrl'] as String? ?? '',
      description: map['description'] as String? ?? '',
      barcode: map['barcode'] as String? ?? '',
      categories: (map['categories'] as List<dynamic>? ?? [])
          .where((e) => e != null)
          .map((e) => ProductCategoryModel.fromMap(Map<dynamic, dynamic>.from(e as Map)))
          .toList(),
      supplier: map['supplier'] != null
          ? ProductSupplierModel.fromMap(Map<dynamic, dynamic>.from(map['supplier'] as Map))
          : null,
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      stock: (map['stock'] as num?)?.toInt() ?? 0,
      minStock: (map['minStock'] as num?)?.toInt() ?? 0,
      isActive: map['isActive'] as bool? ?? true,
      createdAt: DateParser.parse(map['createdAt']),
      updatedAt: DateParser.parse(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'imgUrl': imgUrl,
      'description': description,
      'barcode': barcode,
      'categories': categories.map((e) => e.toMap()).toList(),
      'supplier': supplier?.toMap(),
      'price': price,
      'stock': stock,
      'minStock': minStock,
      'isActive': isActive,
      if (updatedAt != null) 'updatedAt': ServerValue.timestamp,
    };
  }

  ProductEntity toEntity() {
    return ProductEntity(
      id: id,
      name: name,
      imgUrl: imgUrl,
      description: description,
      barcode: barcode,
      categories: categories.map((e) => e.toEntity()).toList(),
      supplier: supplier?.toEntity(),
      price: price,
      stock: stock,
      minStock: minStock,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory ProductModel.fromEntity(ProductEntity entity) {
    return ProductModel(
      id: entity.id,
      name: entity.name,
      imgUrl: entity.imgUrl,
      description: entity.description,
      barcode: entity.barcode,
      categories: entity.categories.map((e) => ProductCategoryModel.fromEntity(e)).toList(),
      supplier: entity.supplier != null ? ProductSupplierModel.fromEntity(entity.supplier!) : null,
      price: entity.price,
      stock: entity.stock,
      minStock: entity.minStock,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
