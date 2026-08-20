import 'dart:async';

import 'package:estoque_pro/app/core/utils/command.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_category_entity.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_entity.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_history_entity.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_supplier_entity.dart';
import 'package:estoque_pro/app/features/products/domain/repositories/products_repository.dart';
import 'package:flutter/foundation.dart';

class ProductsFormViewModel extends ChangeNotifier {
  final ProductsRepository _repository;

  late final Command1<bool, ProductEntity> saveProductCommand;
  late final Command1<bool, ProductEntity> updateProductCommand;
  late final Command1<bool, String> deleteProductCommand;
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

  ProductsFormViewModel(this._repository) {
    saveProductCommand = Command1(_saveProduct);
    updateProductCommand = Command1(_updateProduct);
    deleteProductCommand = Command1(_deleteProduct);
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
      stock: finalStock,
      minStock: minStock,
      isActive: finalStock == 0 ? false : (isEditing ? _isActive : true),
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

  Future<bool> deleteCurrentProduct() async {
    if (_currentProduct == null) return false;
    await deleteProductCommand.execute(_currentProduct!.id);
    return deleteProductCommand.isSuccess;
  }

  Future<Result<bool>> _saveProduct(ProductEntity product) async {
    try {
      if (product.barcode.isNotEmpty) {
        final barcodeExists = await _repository.checkBarcodeExists(product.barcode);
        if (barcodeExists) {
          throw Exception('Já existe um produto cadastrado com este código de barras.');
        }
      }
      await _repository.save(product);
      return const Success(true);
    } catch (e) {
      return Failure(Exception(e.toString()));
    }
  }

  Future<Result<bool>> _updateProduct(ProductEntity product) async {
    try {
      if (product.barcode.isNotEmpty) {
        final barcodeExists = await _repository.checkBarcodeExists(product.barcode, ignoreId: product.id);
        if (barcodeExists) {
          throw Exception('Já existe um produto cadastrado com este código de barras.');
        }
      }
      await _repository.update(product);
      return const Success(true);
    } catch (e) {
      return Failure(Exception(e.toString()));
    }
  }

  Future<Result<bool>> _deleteProduct(String id) async {
    try {
      await _repository.delete(id);
      return const Success(true);
    } catch (e) {
      return Failure(Exception(e.toString()));
    }
  }

  Future<Result<bool>> _adjustStock(({String productId, int quantityDiff, ProductHistoryEntity history}) args) async {
    try {
      await _repository.adjustStock(
        args.productId,
        args.quantityDiff,
        args.history,
      );
      return const Success(true);
    } catch (e) {
      return Failure(Exception(e.toString()));
    }
  }
}
