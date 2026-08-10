import 'dart:async';

import 'package:estoque_pro/app/features/categories/domain/entities/category_entity.dart';
import 'package:estoque_pro/app/features/categories/domain/repositories/categories_repository.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_entity.dart';
import 'package:estoque_pro/app/features/products/domain/repositories/products_repository.dart';
import 'package:flutter/foundation.dart';

enum CategoriesLoadState { idle, loading, success, failure }

class CategoriesViewModel extends ChangeNotifier {
  final CategoriesRepository _repository;
  final ProductsRepository _productsRepository;

  StreamSubscription<List<CategoryEntity>>? _categoriesSubscription;
  StreamSubscription<List<ProductEntity>>? _productsSubscription;

  CategoriesLoadState _state = CategoriesLoadState.idle;
  CategoriesLoadState get state => _state;

  List<CategoryEntity> _categories = [];
  List<CategoryEntity> get categories => _categories;

  List<ProductEntity> _products = [];

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
    return _products.where((p) => p.categories.any((c) => c.id == categoryId)).length;
  }

  Object? _error;
  Object? get error => _error;

  CategoriesViewModel(this._repository, this._productsRepository);

  void listenAll() {
    _state = CategoriesLoadState.loading;
    notifyListeners();

    _categoriesSubscription?.cancel();
    _categoriesSubscription = _repository.watchAll().listen(
      (list) {
        _categories = list..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        _state = CategoriesLoadState.success;
        notifyListeners();
      },
      onError: (e) {
        _error = e;
        _state = CategoriesLoadState.failure;
        notifyListeners();
      },
    );

    _productsSubscription?.cancel();
    _productsSubscription = _productsRepository.watchAll().listen((productsList) {
      _products = productsList;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _categoriesSubscription?.cancel();
    _productsSubscription?.cancel();
    super.dispose();
  }
}
