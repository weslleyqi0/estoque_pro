import 'dart:async';

import 'package:estoque_pro/app/core/utils/command.dart';
import 'package:estoque_pro/app/features/suppliers/domain/entities/supplier_entity.dart';
import 'package:estoque_pro/app/features/suppliers/domain/repositories/suppliers_repository.dart';
import 'package:flutter/foundation.dart';

class SuppliersFormViewmodel extends ChangeNotifier {
  final SuppliersRepository _repository;

  late final Command1<bool, SupplierEntity> saveSupplierCommand;
  late final Command1<bool, SupplierEntity> updateSupplierCommand;
  late final Command1<bool, String> deleteSupplierCommand;

  Object? _error;
  Object? get error => _error;

  SuppliersFormViewmodel(this._repository) {
    saveSupplierCommand = Command1(_saveSupplier);
    updateSupplierCommand = Command1(_updateSupplier);
    deleteSupplierCommand = Command1(_deleteSupplier);
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
      notifyListeners();
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
}
