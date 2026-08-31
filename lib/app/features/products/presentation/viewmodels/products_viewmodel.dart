import 'dart:async';

import 'package:estoque_pro/app/core/base/base_viewmodel.dart';
import 'package:estoque_pro/app/core/utils/command.dart';
import 'package:estoque_pro/app/core/utils/list_extensions.dart';
import 'package:estoque_pro/app/core/utils/string_extensions.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_entity.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_history_entity.dart';
import 'package:estoque_pro/app/features/products/domain/usecases/archive_product_use_case.dart';
import 'package:estoque_pro/app/features/products/domain/usecases/delete_product_permanently_use_case.dart';
import 'package:estoque_pro/app/features/products/domain/usecases/get_products_use_case.dart';
import 'package:estoque_pro/app/features/products/domain/usecases/unarchive_product_use_case.dart';
import 'package:estoque_pro/app/features/products/domain/usecases/watch_product_history_use_case.dart';

class ProductsViewModel extends BaseViewModel {
  final GetProductsUseCase _getProductsUseCase;
  final ArchiveProductUseCase _archiveProductUseCase;
  final UnarchiveProductUseCase _unarchiveProductUseCase;
  final DeleteProductPermanentlyUseCase _deleteProductPermanentlyUseCase;
  final WatchProductHistoryUseCase _watchProductHistoryUseCase;

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

  ProductsViewModel(
    this._getProductsUseCase,
    this._archiveProductUseCase,
    this._unarchiveProductUseCase,
    this._deleteProductPermanentlyUseCase,
    this._watchProductHistoryUseCase,
  ) {
    archiveProductCommand = Command1(_archiveProduct);
    unarchiveProductCommand = Command1(_unarchiveProduct);
    deletePermanentlyCommand = Command1(_deletePermanently);
  }

  void listenAll() {
    if (_subscription != null) return;

    _state = CommandState.running;
    notifyListeners();

    _subscription?.cancel();
    _subscription = _getProductsUseCase.watchAll().listen(
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
    final result = await _archiveProductUseCase(id);
    return result.fold(
      onSuccess: (_) => const Result.success(true),
      onFailure: (failure) => Result.failure(failure),
    );
  }

  AsyncResult<bool> _unarchiveProduct(String id) async {
    final index = _products.indexWhere((p) => p.id == id);
    if (index != -1) {
      _products[index] = _products[index].copyWith(isActive: false, isArchived: false);
      notifyListeners();
    }
    final result = await _unarchiveProductUseCase(id);
    return result.fold(
      onSuccess: (_) => const Result.success(true),
      onFailure: (failure) => Result.failure(failure),
    );
  }

  AsyncResult<bool> _deletePermanently(String id) async {
    _products.removeWhere((p) => p.id == id);
    notifyListeners();
    final result = await _deleteProductPermanentlyUseCase(id);
    return result.fold(
      onSuccess: (_) => const Result.success(true),
      onFailure: (failure) => Result.failure(failure),
    );
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

  StreamSubscription<List<ProductHistoryEntity>>? _historySubscription;
  List<ProductHistoryEntity> _productHistory = [];
  List<ProductHistoryEntity> get productHistory => _productHistory;

  Stream<List<ProductHistoryEntity>> watchProductHistory(String productId, {int limit = 100}) {
    return _watchProductHistoryUseCase(productId, limit: limit);
  }

  void listenProductHistory(String productId, {int limit = 6}) {
    _historySubscription?.cancel();
    _historySubscription = _watchProductHistoryUseCase(productId, limit: limit).listen(
      (history) {
        _productHistory = history;
        notifyListeners();
      },
      onError: (e) {
        _error = e is AppFailure ? e : UnknownFailure(message: e.toString(), error: e);
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _historySubscription?.cancel();
    super.dispose();
  }
}
