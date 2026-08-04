import 'package:estoque_pro/app/features/products/data/models/product_category_model.dart';
import 'package:estoque_pro/app/features/products/data/models/product_history_model.dart';
import 'package:estoque_pro/app/features/products/data/models/product_supplier_model.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_entity.dart';

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
  final List<ProductHistoryModel> history;
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
    this.history = const [],
    this.updatedAt,
  });

  factory ProductModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return ProductModel(
      id: id,
      name: map['name'] as String? ?? '',
      imgUrl: map['imgUrl'] as String? ?? '',
      description: map['description'] as String? ?? '',
      barcode: map['barcode'] as String? ?? '',
      categories: (map['categories'] as List<dynamic>?)
              ?.map((e) => ProductCategoryModel.fromMap(Map<dynamic, dynamic>.from(e as Map)))
              .toList() ??
          [],
      supplier: map['supplier'] != null
          ? ProductSupplierModel.fromMap(Map<dynamic, dynamic>.from(map['supplier'] as Map))
          : null,
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      stock: map['stock'] as int? ?? 0,
      minStock: map['minStock'] as int? ?? 0,
      isActive: map['isActive'] as bool? ?? true,
      history: (map['history'] as List<dynamic>?)
              ?.map((e) => ProductHistoryModel.fromMap(Map<dynamic, dynamic>.from(e as Map)))
              .toList() ??
          [],
      updatedAt: map['updatedAt'] != null 
          ? (map['updatedAt'] is int
              ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int)
              : (int.tryParse(map['updatedAt'].toString()) != null
                  ? DateTime.fromMillisecondsSinceEpoch(int.parse(map['updatedAt'].toString()))
                  : DateTime.tryParse(map['updatedAt'].toString())))
          : null,
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
      'history': history.map((e) => e.toMap()).toList(),
      if (updatedAt != null) 'updatedAt': updatedAt!.millisecondsSinceEpoch,
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
      history: history.map((e) => e.toEntity()).toList(),
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
      history: entity.history.map((e) => ProductHistoryModel.fromEntity(e)).toList(),
      updatedAt: entity.updatedAt,
    );
  }
}
