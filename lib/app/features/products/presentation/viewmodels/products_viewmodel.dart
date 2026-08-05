import 'dart:async';

import 'package:estoque_pro/app/features/products/domain/entities/product_entity.dart';
import 'package:estoque_pro/app/features/products/domain/repositories/products_repository.dart';
import 'package:flutter/foundation.dart';

enum ProductsLoadState { idle, loading, success, failure }

class ProductsViewModel extends ChangeNotifier {
  final ProductsRepository _repository;

  StreamSubscription<List<ProductEntity>>? _subscription;

  ProductsLoadState _state = ProductsLoadState.idle;
  ProductsLoadState get state => _state;

  List<ProductEntity> _products = [];
  List<ProductEntity> get products => _products;

  Object? _error;
  Object? get error => _error;

  ProductsViewModel(this._repository);

  void listenAll() {
    _state = ProductsLoadState.loading;
    notifyListeners();

    _subscription?.cancel();
    _subscription = _repository.watchAll().listen(
      (list) {
        _products = list..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        _state = ProductsLoadState.success;
        notifyListeners();
      },
      onError: (e) {
        _error = e;
        _state = ProductsLoadState.failure;
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
