import 'dart:async';

import 'package:estoque_pro/app/core/utils/command.dart';
import 'package:estoque_pro/app/core/utils/list_extensions.dart';
import 'package:estoque_pro/app/core/utils/string_extensions.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_entity.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_history_entity.dart';
import 'package:estoque_pro/app/features/products/domain/repositories/products_repository.dart';
import 'package:flutter/foundation.dart';

class ProductsViewModel extends ChangeNotifier {
  final ProductsRepository _repository;

  StreamSubscription<List<ProductEntity>>? _subscription;

  late final Command1<bool, String> archiveProductCommand;
  late final Command1<bool, String> unarchiveProductCommand;
  late final Command1<bool, String> deletePermanentlyCommand;

  CommandState _state = CommandState.idle;
  CommandState get state => _state;

  bool get isLoading => _state == CommandState.running;
  bool get isSuccess => _state == CommandState.success;
  bool get isFailure => _state == CommandState.failure;

  List<ProductEntity> _products = [];
  List<ProductEntity> get products => _products;

  List<ProductEntity> get activeProducts => _products.where((p) => !p.isArchived).toList();

  List<ProductEntity> get archivedProducts => _products.where((p) => p.isArchived).toList();

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  bool _showOnlyLowStock = false;
  bool get showOnlyLowStock => _showOnlyLowStock;

  List<ProductEntity> get lowStockProducts => _products.where((p) => p.stock < p.minStock && p.isActive).toList();

  bool get hasLowStock => lowStockProducts.isNotEmpty;

  void setShowOnlyLowStock(bool value, {bool notify = true}) {
    if (_showOnlyLowStock == value) return;
    _showOnlyLowStock = value;
    if (notify) notifyListeners();
  }

  void clearLowStockFilter({bool notify = true}) {
    if (!_showOnlyLowStock) return;
    _showOnlyLowStock = false;
    if (notify) notifyListeners();
  }

  void setSearchQuery(String query, {bool notify = true}) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    if (notify) notifyListeners();
  }

  ProductEntity? findProductByBarcode(String barcode) {
    final normalized = barcode.normalizedBarcode;
    if (normalized.isEmpty) return null;
    for (final product in _products) {
      if (product.barcode.trim() == barcode.trim() || product.barcode.normalizedBarcode == normalized) {
        return product;
      }
    }
    return null;
  }

  List<ProductEntity> get filteredProducts {
    final list = _showOnlyLowStock ? lowStockProducts : activeProducts;

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

  ProductsViewModel(this._repository) {
    archiveProductCommand = Command1(_archiveProduct);
    unarchiveProductCommand = Command1(_unarchiveProduct);
    deletePermanentlyCommand = Command1(_deletePermanently);
  }

  void listenAll() {
    if (_subscription != null) return;

    _state = CommandState.running;
    notifyListeners();

    _subscription?.cancel();
    _subscription = _repository.watchAll().listen(
      (list) {
        _products = list.sortByName((a) => a.name);
        _state = CommandState.success;
        notifyListeners();
      },
      onError: (e) {
        _error = e is AppFailure ? e : UnknownFailure(message: e.toString(), error: e);
        _state = CommandState.failure;
        notifyListeners();
      },
    );
  }

  AsyncResult<bool> _archiveProduct(String id) async {
    final index = _products.indexWhere((p) => p.id == id);
    if (index != -1) {
      _products[index] = _products[index].copyWith(isActive: false, isArchived: true);
      notifyListeners();
    }
    return Result.guard(() async {
      await _repository.archive(id);
      return true;
    });
  }

  AsyncResult<bool> _unarchiveProduct(String id) async {
    final index = _products.indexWhere((p) => p.id == id);
    if (index != -1) {
      _products[index] = _products[index].copyWith(isActive: false, isArchived: false);
      notifyListeners();
    }
    return Result.guard(() async {
      await _repository.unarchive(id);
      return true;
    });
  }

  AsyncResult<bool> _deletePermanently(String id) async {
    _products.removeWhere((p) => p.id == id);
    notifyListeners();
    return Result.guard(() async {
      await _repository.deletePermanently(id);
      return true;
    });
  }

  Future<void> archiveProduct(String id) async {
    await archiveProductCommand.execute(id);
    if (archiveProductCommand.isFailure) {
      throw archiveProductCommand.error!;
    }
  }

  Future<void> unarchiveProduct(String id) async {
    await unarchiveProductCommand.execute(id);
    if (unarchiveProductCommand.isFailure) {
      throw unarchiveProductCommand.error!;
    }
  }

  Future<void> deletePermanently(String id) async {
    await deletePermanentlyCommand.execute(id);
    if (deletePermanentlyCommand.isFailure) {
      throw deletePermanentlyCommand.error!;
    }
  }

  Stream<List<ProductHistoryEntity>> watchProductHistory(String productId, {int limit = 100}) {
    return _repository.watchHistory(productId, limit: limit);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
