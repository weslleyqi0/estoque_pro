import 'dart:async';

import 'package:estoque_pro/app/features/suppliers/domain/entities/supplier_entity.dart';
import 'package:estoque_pro/app/features/suppliers/domain/repositories/suppliers_repository.dart';
import 'package:flutter/foundation.dart';

enum SuppliersLoadState { indle, loading, success, failure }

class SuppliersViewModel extends ChangeNotifier {
  final SuppliersRepository _repository;

  StreamSubscription<List<SupplierEntity>>? _subscription;

  SuppliersLoadState _state = SuppliersLoadState.indle;
  SuppliersLoadState get state => _state;

  List<SupplierEntity> _suppliers = [];
  List<SupplierEntity> get suppliers => _suppliers;

  Object? _error;
  Object? get error => _error;

  SuppliersViewModel(this._repository);

  void listenAll() {
    _state = SuppliersLoadState.loading;
    notifyListeners();

    _subscription?.cancel();
    _subscription = _repository.watchAll().listen(
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
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
