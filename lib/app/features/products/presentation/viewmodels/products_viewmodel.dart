import 'dart:async';

import 'package:estoque_pro/app/core/utils/string_extensions.dart';

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

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  bool _showOnlyLowStock = false;
  bool get showOnlyLowStock => _showOnlyLowStock;

  List<ProductEntity> get lowStockProducts =>
      _products.where((p) => p.stock < p.minStock && p.isActive).toList();

  bool get hasLowStock => lowStockProducts.isNotEmpty;

  void setShowOnlyLowStock(bool value) {
    _showOnlyLowStock = value;
    notifyListeners();
  }

  void clearLowStockFilter() {
    _showOnlyLowStock = false;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  List<ProductEntity> get filteredProducts {
    final list = _showOnlyLowStock ? lowStockProducts : _products;

    if (_searchQuery.trim().isEmpty) return list;

    final query = _searchQuery.withoutDiacritics.toLowerCase().trim();

    return list.where((product) {
      final matchesName = product.name.withoutDiacritics.toLowerCase().contains(query);
      final matchesBarcode = product.barcode.withoutDiacritics.toLowerCase().contains(query);
      final matchesDesc = product.description.withoutDiacritics.toLowerCase().contains(query);
      final matchesSupplier = product.supplier?.name.withoutDiacritics.toLowerCase().contains(query) ?? false;
      final matchesCategory = product.categories.any((c) => c.name.withoutDiacritics.toLowerCase().contains(query));

      return matchesName || matchesBarcode || matchesDesc || matchesSupplier || matchesCategory;
    }).toList();
  }

  Object? _error;
  Object? get error => _error;

  ProductsViewModel(this._repository);

  void listenAll() {
    if (_subscription != null) return;

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
