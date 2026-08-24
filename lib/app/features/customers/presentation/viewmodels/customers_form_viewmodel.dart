import 'dart:async';

import 'package:estoque_pro/app/core/utils/command.dart';
import 'package:estoque_pro/app/features/customers/domain/entities/customer_entity.dart';
import 'package:estoque_pro/app/features/customers/domain/repositories/customers_repository.dart';
import 'package:flutter/foundation.dart';

class CustomersFormViewModel extends ChangeNotifier {
  final CustomersRepository _repository;

  late final Command1<bool, CustomerEntity> saveCustomerCommand;
  late final Command1<bool, CustomerEntity> updateCustomerCommand;
  late final Command1<bool, String> deleteCustomerCommand;

  Object? _error;
  Object? get error => _error;

  CustomersFormViewModel(this._repository) {
    saveCustomerCommand = Command1(_saveCustomer);
    updateCustomerCommand = Command1(_updateCustomer);
    deleteCustomerCommand = Command1(_deleteCustomer);
  }

  Future<Result<bool>> _saveCustomer(CustomerEntity customer) async {
    try {
      await _repository.save(customer);
      return const Success(true);
    } catch (e) {
      return Failure(Exception(e.toString()));
    }
  }

  Future<Result<bool>> _updateCustomer(CustomerEntity customer) async {
    try {
      await _repository.update(customer);
      notifyListeners();
      return const Success(true);
    } catch (e) {
      return Failure(Exception(e.toString()));
    }
  }

  Future<Result<bool>> _deleteCustomer(String id) async {
    try {
      await _repository.delete(id);
      return const Success(true);
    } catch (e) {
      return Failure(Exception(e.toString()));
    }
  }
}
