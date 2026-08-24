import 'dart:async';

import 'package:estoque_pro/app/core/services/firebase_database_service.dart';
import 'package:estoque_pro/app/core/utils/list_extensions.dart';
import 'package:estoque_pro/app/features/customers/data/models/customer_model.dart';
import 'package:estoque_pro/app/features/customers/domain/entities/customer_entity.dart';
import 'package:estoque_pro/app/features/customers/domain/repositories/customers_repository.dart';
import 'package:flutter/foundation.dart';

class CustomersRepositoryImpl implements CustomersRepository {
  final FirebaseDatabaseService _firebaseDb;

  CustomersRepositoryImpl(this._firebaseDb);

  @override
  Stream<List<CustomerEntity>> watchAll() {
    return _firebaseDb
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
          debugPrint('---> Customers: Erro no listener Firebase: $e');
        });
  }

  @override
  Future<List<CustomerEntity>> getAll() async {
    try {
      final data = await _firebaseDb.getOnce();
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
      debugPrint('---> Customers: Erro getAll Firebase: $e');
      return [];
    }
  }

  @override
  Future<void> save(CustomerEntity customer) async {
    final model = CustomerModel.fromEntity(customer);
    try {
      await _firebaseDb.add(model.toMap());
    } catch (e) {
      debugPrint('---> Customers: Erro ao salvar no Firebase: $e');
      rethrow;
    }
  }

  @override
  Future<void> update(CustomerEntity customer) async {
    final model = CustomerModel.fromEntity(customer);
    try {
      await _firebaseDb.update(customer.id, model.toMap());
    } catch (e) {
      debugPrint('---> Customers: Erro ao atualizar no Firebase: $e');
      rethrow;
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _firebaseDb.delete(id);
    } catch (e) {
      debugPrint('---> Customers: Erro ao deletar no Firebase: $e');
      rethrow;
    }
  }
}
