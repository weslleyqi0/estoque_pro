import 'dart:async';

import 'package:estoque_pro/app/features/products/domain/entities/product_entity.dart';
import 'package:estoque_pro/app/features/products/domain/repositories/products_repository.dart';
import 'package:estoque_pro/app/features/suppliers/domain/entities/supplier_entity.dart';
import 'package:estoque_pro/app/features/suppliers/domain/repositories/suppliers_repository.dart';
import 'package:flutter/foundation.dart';

enum SuppliersLoadState { idle, loading, success, failure }

class SuppliersViewModel extends ChangeNotifier {
  final SuppliersRepository _repository;
  final ProductsRepository _productsRepository;

  StreamSubscription<List<SupplierEntity>>? _suppliersSubscription;
  StreamSubscription<List<ProductEntity>>? _productsSubscription;

  SuppliersLoadState _state = SuppliersLoadState.idle;
  SuppliersLoadState get state => _state;

  List<SupplierEntity> _suppliers = [];
  List<SupplierEntity> get suppliers => _suppliers;

  List<ProductEntity> _products = [];

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  List<SupplierEntity> get filteredSuppliers {
    if (_searchQuery.trim().isEmpty) return _suppliers;

    final query = _searchQuery.toLowerCase().trim();
    final queryDigits = query.replaceAll(RegExp(r'\D'), '');
    final isSearchingNumbers = queryDigits.isNotEmpty;

    return _suppliers.where((supplier) {
      final nameMatches = supplier.name.toLowerCase().contains(query);

      var cnpjMatches = false;
      var phoneMatches = false;

      if (isSearchingNumbers) {
        final cnpjDigits = supplier.cnpj?.replaceAll(RegExp(r'\D'), '') ?? '';
        final phoneDigits = supplier.phone?.replaceAll(RegExp(r'\D'), '') ?? '';

        cnpjMatches = cnpjDigits.contains(queryDigits);
        phoneMatches = phoneDigits.contains(queryDigits);
      } else {
        cnpjMatches = supplier.cnpj?.toLowerCase().contains(query) ?? false;
        phoneMatches = supplier.phone?.toLowerCase().contains(query) ?? false;
      }

      return nameMatches || cnpjMatches || phoneMatches;
    }).toList();
  }

  int getProductCountForSupplier(String supplierId) {
    return _products.where((p) => p.supplier?.id == supplierId).length;
  }

  Object? _error;
  Object? get error => _error;

  SuppliersViewModel(this._repository, this._productsRepository);

  void listenAll() {
    _state = SuppliersLoadState.loading;
    notifyListeners();

    _suppliersSubscription?.cancel();
    _suppliersSubscription = _repository.watchAll().listen(
      (list) {
        _suppliers = list..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        _state = SuppliersLoadState.success;
        notifyListeners();
      },
      onError: (e) {
        _error = e;
        _state = SuppliersLoadState.failure;
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
    _suppliersSubscription?.cancel();
    _productsSubscription?.cancel();
    super.dispose();
  }
}
