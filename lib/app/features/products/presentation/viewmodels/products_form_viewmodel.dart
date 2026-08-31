import 'dart:async';

import 'package:estoque_pro/app/core/utils/command.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_category_entity.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_entity.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_history_entity.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_supplier_entity.dart';
import 'package:estoque_pro/app/features/products/domain/usecases/adjust_stock_use_case.dart';
import 'package:estoque_pro/app/features/products/domain/usecases/archive_product_use_case.dart';
import 'package:estoque_pro/app/features/products/domain/usecases/save_product_use_case.dart';
import 'package:estoque_pro/app/features/products/domain/usecases/unarchive_product_use_case.dart';
import 'package:estoque_pro/app/features/products/domain/usecases/update_product_use_case.dart';
import 'package:flutter/foundation.dart';

class ProductsFormViewModel extends ChangeNotifier {
  final SaveProductUseCase _saveProductUseCase;
  final UpdateProductUseCase _updateProductUseCase;
  final ArchiveProductUseCase _archiveProductUseCase;
  final UnarchiveProductUseCase _unarchiveProductUseCase;
  final AdjustStockUseCase _adjustStockUseCase;

  late final Command1<bool, ProductEntity> saveProductCommand;
  late final Command1<bool, ProductEntity> updateProductCommand;
  late final Command1<bool, String> archiveProductCommand;
  late final Command1<bool, String> unarchiveProductCommand;
  late final Command1<bool, ({String productId, int quantityDiff, ProductHistoryEntity history})> adjustStockCommand;

  ProductEntity? _currentProduct;
  ProductEntity? get currentProduct => _currentProduct;
  bool get isEditing => _currentProduct != null;

  int _stock = 0;
  int get stock => _stock;

  bool _isActive = true;
  bool get isActive => _isActive;
  void setActive(bool value) {
    _isActive = value;
    notifyListeners();
  }

  List<ProductCategoryEntity> _selectedCategories = [];
  List<ProductCategoryEntity> get selectedCategories => _selectedCategories;
  void setCategories(List<ProductCategoryEntity> categories) {
    _selectedCategories = List.from(categories);
    notifyListeners();
  }

  ProductSupplierEntity? _selectedSupplier;
  ProductSupplierEntity? get selectedSupplier => _selectedSupplier;
  void setSupplier(ProductSupplierEntity? supplier) {
    _selectedSupplier = supplier;
    notifyListeners();
  }

  Object? _error;
  Object? get error => _error;

  ProductsFormViewModel(
    this._saveProductUseCase,
    this._updateProductUseCase,
    this._archiveProductUseCase,
    this._unarchiveProductUseCase,
    this._adjustStockUseCase,
  ) {
    saveProductCommand = Command1(_saveProduct);
    updateProductCommand = Command1(_updateProduct);
    archiveProductCommand = Command1(_archiveProduct);
    unarchiveProductCommand = Command1(_unarchiveProduct);
    adjustStockCommand = Command1(_adjustStock);
  }

  void init(ProductEntity? product) {
    _currentProduct = product;
    _stock = product?.stock ?? 0;
    _isActive = product?.isActive ?? true;
    _selectedCategories = product?.categories ?? [];
    _selectedSupplier = product?.supplier;
    notifyListeners();
  }

  Future<bool> saveForm({
    required String name,
    required String imgUrl,
    required String description,
    required String barcode,
    required double price,
    double costPrice = 0.0,
    required int minStock,
    int initialStock = 0,
  }) async {
    final finalStock = isEditing ? _stock : initialStock;
    final product = ProductEntity(
      id: _currentProduct?.id ?? '',
      name: name.trim(),
      imgUrl: imgUrl.trim(),
      description: description.trim(),
      barcode: barcode.trim(),
      categories: _selectedCategories,
      supplier: _selectedSupplier,
      price: price,
      costPrice: costPrice,
      stock: finalStock,
      minStock: minStock,
      isActive: finalStock == 0
          ? false
          : (isEditing ? ((_currentProduct?.isArchived ?? false) ? false : _isActive) : true),
      isArchived: _currentProduct?.isArchived ?? false,
      updatedAt: DateTime.now(),
    );

    if (isEditing) {
      await updateProductCommand.execute(product);
      return updateProductCommand.isSuccess;
    } else {
      await saveProductCommand.execute(product);
      return saveProductCommand.isSuccess;
    }
  }

  Future<bool> archiveCurrentProduct() async {
    if (_currentProduct == null) return false;
    await archiveProductCommand.execute(_currentProduct!.id);
    return archiveProductCommand.isSuccess;
  }

  Future<bool> unarchiveCurrentProduct() async {
    if (_currentProduct == null) return false;
    await unarchiveProductCommand.execute(_currentProduct!.id);
    return unarchiveProductCommand.isSuccess;
  }

  Future<Result<bool>> _saveProduct(ProductEntity product) async {
    final result = await _saveProductUseCase(product);
    return result.fold(
      onSuccess: (_) => const Result.success(true),
      onFailure: (failure) => Result.failure(failure),
    );
  }

  Future<Result<bool>> _updateProduct(ProductEntity product) async {
    final result = await _updateProductUseCase(product);
    return result.fold(
      onSuccess: (_) => const Result.success(true),
      onFailure: (failure) => Result.failure(failure),
    );
  }

  Future<Result<bool>> _archiveProduct(String id) async {
    final result = await _archiveProductUseCase(id);
    return result.fold(
      onSuccess: (_) => const Result.success(true),
      onFailure: (failure) => Result.failure(failure),
    );
  }

  Future<Result<bool>> _unarchiveProduct(String id) async {
    final result = await _unarchiveProductUseCase(id);
    return result.fold(
      onSuccess: (_) => const Result.success(true),
      onFailure: (failure) => Result.failure(failure),
    );
  }

  Future<Result<bool>> _adjustStock(
    ({String productId, int quantityDiff, ProductHistoryEntity history}) args,
  ) async {
    final result = await _adjustStockUseCase(
      productId: args.productId,
      quantityDiff: args.quantityDiff,
      history: args.history,
    );
    return result.fold(
      onSuccess: (_) => const Result.success(true),
      onFailure: (failure) => Result.failure(failure),
    );
  }
}
