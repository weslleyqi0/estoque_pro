import 'dart:async';

import 'package:estoque_pro/app/core/utils/command.dart';
import 'package:estoque_pro/app/features/suppliers/domain/entities/supplier_entity.dart';
import 'package:estoque_pro/app/features/suppliers/domain/repositories/suppliers_repository.dart';
import 'package:flutter/foundation.dart';

enum SuppliersLoadState { loading, success, failure }

class SuppliersViewModel extends ChangeNotifier {
  final SuppliersRepository _repository;

  StreamSubscription<List<SupplierEntity>>? _subscription;
  late final Command1<bool, SupplierEntity> saveSupplierCommand;
  late final Command1<bool, SupplierEntity> updateSupplierCommand;
  late final Command1<bool, String> deleteSupplierCommand;

  SuppliersLoadState _state = SuppliersLoadState.loading;
  SuppliersLoadState get state => _state;

  List<SupplierEntity> _suppliers = [];
  List<SupplierEntity> get suppliers => _suppliers;

  Object? _error;
  Object? get error => _error;

  SuppliersViewModel(this._repository) {
    saveSupplierCommand = Command1(_saveSupplier);
    saveSupplierCommand = Command1(_updateSupplier);
    deleteSupplierCommand = Command1(_deleteSupplier);
  }

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

  Future<Result<bool>> _saveSupplier(SupplierEntity supplier) async {
    try {
      await _repository.save(supplier);
      return const Success(true);
    } catch (e) {
      return Failure(Exception(e.toString()));
    }
  }

  Future<Result<bool>> _updateSupplier(SupplierEntity supplier) async {
    try {
      await _repository.update(supplier);
      return const Success(true);
    } catch (e) {
      return Failure(Exception(e.toString()));
    }
  }

  Future<Result<bool>> _deleteSupplier(String id) async {
    try {
      await _repository.delete(id);
      return const Success(true);
    } catch (e) {
      return Failure(Exception(e.toString()));
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
