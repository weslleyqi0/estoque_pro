import 'dart:async';

import 'package:estoque_pro/app/core/services/database_service.dart';
import 'package:estoque_pro/app/core/utils/list_extensions.dart';
import 'package:estoque_pro/app/features/customers/data/models/customer_model.dart';
import 'package:estoque_pro/app/features/customers/domain/entities/customer_entity.dart';
import 'package:estoque_pro/app/features/customers/domain/repositories/customers_repository.dart';
import 'package:flutter/foundation.dart';

class CustomersRepositoryImpl implements CustomersRepository {
  final DatabaseService<CustomerEntity> _databaseService;

  CustomersRepositoryImpl(this._databaseService);

  @override
  Stream<List<CustomerEntity>> watchAll() {
    return _databaseService
        .listen()
        .map((data) {
          final List<CustomerEntity> entities = [];
          if (data != null) {
            for (final entry in data.entries) {
              if (entry.value is Map) {
                final model = CustomerModel.fromMap(
                  entry.key,
                  Map<dynamic, dynamic>.from(entry.value as Map),
                );
                entities.add(model.toEntity());
              }
            }
          }
          return entities.sortByName((a) => a.name);
        })
        .handleError((e) {
          debugPrint('---> Customers: Erro no listener: $e');
        });
  }

  @override
  Future<List<CustomerEntity>> getAll() async {
    try {
      final data = await _databaseService.getOnce();
      final List<CustomerEntity> entities = [];
      if (data != null) {
        for (final entry in data.entries) {
          if (entry.value is Map) {
            final model = CustomerModel.fromMap(
              entry.key,
              Map<dynamic, dynamic>.from(entry.value as Map),
            );
            entities.add(model.toEntity());
          }
        }
      }
      return entities;
    } catch (e) {
      debugPrint('---> Customers: Erro getAll: $e');
      return [];
    }
  }

  @override
  Future<void> save(CustomerEntity customer) async {
    final model = CustomerModel.fromEntity(customer);
    try {
      await _databaseService.add(model.toMap());
    } catch (e) {
      debugPrint('---> Customers: Erro ao salvar: $e');
      rethrow;
    }
  }

  @override
  Future<void> update(CustomerEntity customer) async {
    final model = CustomerModel.fromEntity(customer);
    try {
      await _databaseService.update(customer.id, model.toMap());
    } catch (e) {
      debugPrint('---> Customers: Erro ao atualizar: $e');
      rethrow;
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _databaseService.delete(id);
    } catch (e) {
      debugPrint('---> Customers: Erro ao deletar: $e');
      rethrow;
    }
  }
}
