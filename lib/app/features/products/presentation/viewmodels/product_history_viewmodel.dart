import 'dart:async';

import 'package:estoque_pro/app/features/products/domain/entities/product_history_entity.dart';
import 'package:estoque_pro/app/features/products/domain/usecases/watch_product_history_use_case.dart';
import 'package:flutter/foundation.dart';

enum ProductHistoryLoadState { idle, loading, success, failure }

class ProductHistoryViewModel extends ChangeNotifier {
  final WatchProductHistoryUseCase _watchProductHistoryUseCase;

  StreamSubscription<List<ProductHistoryEntity>>? _subscription;

  ProductHistoryLoadState _state = ProductHistoryLoadState.idle;
  ProductHistoryLoadState get state => _state;

  List<ProductHistoryEntity> _history = [];
  List<ProductHistoryEntity> get history => _history;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _hasMore = true;
  bool get hasMore => _hasMore;

  int _itemsToShow = 20;
  int get itemsToShow => _itemsToShow;

  Object? _error;
  Object? get error => _error;

  ProductHistoryViewModel(this._watchProductHistoryUseCase);

  void listenHistory(String productId) {
    _subscription?.cancel();
    _state = ProductHistoryLoadState.loading;
    _isLoading = true;
    notifyListeners();

    _subscription = _watchProductHistoryUseCase(productId, limit: _itemsToShow).listen(
      (data) {
        _history = data;
        _isLoading = false;
        _hasMore = data.length >= _itemsToShow;
        _state = ProductHistoryLoadState.success;
        notifyListeners();
      },
      onError: (e) {
        _error = e;
        _isLoading = false;
        _state = ProductHistoryLoadState.failure;
        notifyListeners();
      },
    );
  }

  void loadMore(String productId) {
    if (_isLoading || !_hasMore) return;
    _itemsToShow += 20;
    listenHistory(productId);
  }

  Stream<List<ProductHistoryEntity>> watchHistory(String productId, {int limit = 100}) {
    return _watchProductHistoryUseCase(productId, limit: limit);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
