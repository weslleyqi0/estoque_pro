import 'dart:async';

import 'package:estoque_pro/app/core/utils/list_extensions.dart';
import 'package:estoque_pro/app/features/categories/domain/entities/category_entity.dart';
import 'package:estoque_pro/app/features/categories/domain/repositories/categories_repository.dart';
import 'package:estoque_pro/app/features/products/domain/usecases/count_products_use_case.dart';
import 'package:flutter/foundation.dart';

enum CategoriesLoadState { idle, loading, success, failure }

class CategoriesViewModel extends ChangeNotifier {
  final CategoriesRepository _repository;
  final CountProductsUseCase _countProductsUseCase;

  StreamSubscription<List<CategoryEntity>>? _categoriesSubscription;
  final List<StreamSubscription<int>> _productCountSubscriptions = [];

  CategoriesLoadState _state = CategoriesLoadState.idle;
  CategoriesLoadState get state => _state;

  List<CategoryEntity> _categories = [];
  List<CategoryEntity> get categories => _categories;

  final Map<String, int> _categoryProductCounts = {};

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  List<CategoryEntity> get filteredCategories {
    if (_searchQuery.trim().isEmpty) return _categories;

    final query = _searchQuery.toLowerCase().trim();

    return _categories.where((category) {
      return category.name.toLowerCase().contains(query);
    }).toList();
  }

  int getProductCountForCategory(String categoryId) {
    return _categoryProductCounts[categoryId] ?? 0;
  }

  void _loadProductCounts() {
    for (final subscription in _productCountSubscriptions) {
      subscription.cancel();
    }
    _productCountSubscriptions.clear();

    for (final category in _categories) {
      final subscription = _countProductsUseCase.countByCategory(category.id).listen((count) {
        _categoryProductCounts[category.id] = count;
        notifyListeners();
      });
      _productCountSubscriptions.add(subscription);
    }
  }

  Object? _error;
  Object? get error => _error;

  CategoriesViewModel(this._repository, this._countProductsUseCase);

  void listenAll() {
    _state = CategoriesLoadState.loading;
    notifyListeners();

    _categoriesSubscription?.cancel();
    _categoriesSubscription = _repository.watchAll().listen(
      (list) {
        _categories = list.sortByName((a) => a.name);
        _state = CategoriesLoadState.success;
        _loadProductCounts();
        notifyListeners();
      },
      onError: (e) {
        _error = e;
        _state = CategoriesLoadState.failure;
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _categoriesSubscription?.cancel();
    for (final subscription in _productCountSubscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }
}
