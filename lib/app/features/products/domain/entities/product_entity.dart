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
  final double costPrice;
  final int stock;
  final int minStock;
  final bool isActive;
  final bool isArchived;
  final DateTime? createdAt;
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
    this.costPrice = 0.0,
    required this.stock,
    required this.minStock,
    this.isActive = true,
    this.isArchived = false,
    this.createdAt,
    this.updatedAt,
  });

  /// Unit gross profit (Selling price - Cost price)
  double get unitProfit => price - costPrice;

  /// Profit margin percentage based on selling price
  double get marginPercent => price > 0 ? (unitProfit / price) * 100 : 0.0;

  /// Markup percentage over cost price
  double get markupPercent => costPrice > 0 ? (unitProfit / costPrice) * 100 : 0.0;

  /// Total value invested in current stock based on cost price
  double get totalCostStock => costPrice * stock;

  /// Total projected sales revenue with current stock
  double get totalSellingStock => price * stock;

  /// Total projected profit with current stock
  double get totalProjectedProfit => unitProfit * stock;

  ProductEntity copyWith({
    String? id,
    String? name,
    String? imgUrl,
    String? description,
    String? barcode,
    List<ProductCategoryEntity>? categories,
    ProductSupplierEntity? supplier,
    double? price,
    double? costPrice,
    int? stock,
    int? minStock,
    bool? isActive,
    bool? isArchived,
    DateTime? createdAt,
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
      costPrice: costPrice ?? this.costPrice,
      stock: stock ?? this.stock,
      minStock: minStock ?? this.minStock,
      isActive: isActive ?? this.isActive,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
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
    costPrice,
    stock,
    minStock,
    isActive,
    isArchived,
    createdAt,
    updatedAt,
  ];
}
