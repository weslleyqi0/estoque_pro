import 'dart:async';

import 'package:estoque_pro/app/features/categories/domain/entities/category_entity.dart';
import 'package:estoque_pro/app/features/categories/domain/repositories/categories_repository.dart';
import 'package:flutter/foundation.dart';

enum CategoriesLoadState { idle, loading, success, failure }

class CategoriesViewModel extends ChangeNotifier {
  final CategoriesRepository _repository;

  StreamSubscription<List<CategoryEntity>>? _subscription;

  CategoriesLoadState _state = CategoriesLoadState.idle;
  CategoriesLoadState get state => _state;

  List<CategoryEntity> _categories = [];
  List<CategoryEntity> get categories => _categories;

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

  Object? _error;
  Object? get error => _error;

  CategoriesViewModel(this._repository);

  void listenAll() {
    _state = CategoriesLoadState.loading;
    notifyListeners();

    _subscription?.cancel();
    _subscription = _repository.watchAll().listen(
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
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
