import 'dart:async';

import 'package:estoque_pro/app/core/utils/command.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_entity.dart';
import 'package:estoque_pro/app/features/products/domain/repositories/products_repository.dart';
import 'package:flutter/foundation.dart';

class ProductsFormViewModel extends ChangeNotifier {
  final ProductsRepository _repository;

  late final Command1<bool, ProductEntity> saveProductCommand;
  late final Command1<bool, ProductEntity> updateProductCommand;
  late final Command1<bool, String> deleteProductCommand;

  Object? _error;
  Object? get error => _error;

  ProductsFormViewModel(this._repository) {
    saveProductCommand = Command1(_saveProduct);
    updateProductCommand = Command1(_updateProduct);
    deleteProductCommand = Command1(_deleteProduct);
  }

  Future<Result<bool>> _saveProduct(ProductEntity product) async {
    try {
      await _repository.save(product);
      return const Success(true);
    } catch (e) {
      return Failure(Exception(e.toString()));
    }
  }

  Future<Result<bool>> _updateProduct(ProductEntity product) async {
    try {
      await _repository.update(product);
      notifyListeners();
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
}
