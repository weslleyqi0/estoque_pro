import 'dart:async';

import 'package:estoque_pro/app/core/utils/string_extensions.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_entity.dart';
import 'package:estoque_pro/app/features/products/domain/repositories/products_repository.dart';
import 'package:flutter/foundation.dart';

enum ArchivedProductsLoadState { idle, loading, success, failure }

class ArchivedProductsViewModel extends ChangeNotifier {
  final ProductsRepository _repository;

  StreamSubscription<List<ProductEntity>>? _subscription;

  ArchivedProductsLoadState _state = ArchivedProductsLoadState.idle;
  ArchivedProductsLoadState get state => _state;

  List<ProductEntity> _products = [];
  List<ProductEntity> get archivedProducts => _products.where((p) => p.isArchived).toList();

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  void setSearchQuery(String query, {bool notify = true}) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    if (notify) notifyListeners();
  }

  List<ProductEntity> get filteredArchivedProducts {
    final list = archivedProducts;

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

  ArchivedProductsViewModel(this._repository);

  void listenAll() {
    if (_subscription != null) return;

    _state = ArchivedProductsLoadState.loading;
    notifyListeners();

    _subscription?.cancel();
    _subscription = _repository.watchAll().listen(
      (list) {
        _products = list..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        _state = ArchivedProductsLoadState.success;
        notifyListeners();
      },
      onError: (e) {
        _error = e;
        _state = ArchivedProductsLoadState.failure;
        notifyListeners();
      },
    );
  }

  Future<void> unarchiveProduct(String id) async {
    try {
      final index = _products.indexWhere((p) => p.id == id);
      if (index != -1) {
        _products[index] = _products[index].copyWith(isActive: false, isArchived: false);
        notifyListeners();
      }
      await _repository.unarchive(id);
    } catch (e) {
      _error = e;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deletePermanently(String id) async {
    try {
      final index = _products.indexWhere((p) => p.id == id);
      if (index != -1) {
        _products.removeAt(index);
        notifyListeners();
      }
      await _repository.deletePermanently(id);
    } catch (e) {
      _error = e;
      notifyListeners();
      rethrow;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
