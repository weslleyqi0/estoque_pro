import 'dart:async';

import 'package:estoque_pro/app/core/base/base_viewmodel.dart';
import 'package:estoque_pro/app/core/utils/command.dart';
import 'package:estoque_pro/app/core/utils/list_extensions.dart';
import 'package:estoque_pro/app/core/utils/string_extensions.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_entity.dart';
import 'package:estoque_pro/app/features/products/domain/usecases/delete_product_permanently_use_case.dart';
import 'package:estoque_pro/app/features/products/domain/usecases/get_products_use_case.dart';
import 'package:estoque_pro/app/features/products/domain/usecases/unarchive_product_use_case.dart';

enum ArchivedProductsLoadState { idle, loading, success, failure }

class ArchivedProductsViewModel extends BaseViewModel {
  final GetProductsUseCase _getProductsUseCase;
  final UnarchiveProductUseCase _unarchiveProductUseCase;
  final DeleteProductPermanentlyUseCase _deleteProductPermanentlyUseCase;

  StreamSubscription<List<ProductEntity>>? _subscription;

  late final Command1<bool, String> unarchiveProductCommand;
  late final Command1<bool, String> deletePermanentlyCommand;

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

  ArchivedProductsViewModel(
    this._getProductsUseCase,
    this._unarchiveProductUseCase,
    this._deleteProductPermanentlyUseCase,
  ) {
    unarchiveProductCommand = Command1(_unarchiveProduct);
    deletePermanentlyCommand = Command1(_deletePermanently);
  }

  void listenAll() {
    if (_subscription != null) return;

    _state = ArchivedProductsLoadState.loading;
    notifyListeners();

    _subscription?.cancel();
    _subscription = _getProductsUseCase.watchAll().listen(
      (list) {
        _products = list.sortByName((a) => a.name);
        _state = ArchivedProductsLoadState.success;
        notifyListeners();
      },
      onError: (e) {
        _error = e is AppFailure ? e : UnknownFailure(message: e.toString(), error: e);
        _state = ArchivedProductsLoadState.failure;
        notifyListeners();
      },
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
    final index = _products.indexWhere((p) => p.id == id);
    if (index != -1) {
      _products.removeAt(index);
      notifyListeners();
    }
    final result = await _deleteProductPermanentlyUseCase(id);
    return result.fold(
      onSuccess: (_) => const Result.success(true),
      onFailure: (failure) => Result.failure(failure),
    );
  }



  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
