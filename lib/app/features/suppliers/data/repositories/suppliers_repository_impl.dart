import 'dart:async';

import 'package:estoque_pro/app/core/services/firebase_database_service.dart';
import 'package:estoque_pro/app/features/suppliers/data/models/supplier_model.dart';
import 'package:estoque_pro/app/features/suppliers/domain/entities/supplier_entity.dart';
import 'package:estoque_pro/app/features/suppliers/domain/repositories/suppliers_repository.dart';
import 'package:flutter/foundation.dart';

class SuppliersRepositoryImpl implements SuppliersRepository {
  final FirebaseDatabaseService _firebaseDb;

  SuppliersRepositoryImpl(
    this._firebaseDb,
  );

  @override
  Stream<List<SupplierEntity>> watchAll() {
    return _firebaseDb
        .listen()
        .map((data) {
          final List<SupplierEntity> entities = [];
          if (data != null) {
            for (final entry in data.entries) {
              if (entry.value is Map) {
                final model = SupplierModel.fromMap(
                  entry.key,
                  Map<dynamic, dynamic>.from(entry.value as Map),
                );
                entities.add(model.toEntity());
              }
            }
          }
          return entities..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        })
        .handleError((e) {
          debugPrint('---> Suppliers: Erro no listener Firebase: $e');
        });
  }

  @override
  Future<List<SupplierEntity>> getAll() async {
    try {
      final data = await _firebaseDb.getOnce();
      final List<SupplierEntity> entities = [];
      if (data != null) {
        for (final entry in data.entries) {
          if (entry.value is Map) {
            final model = SupplierModel.fromMap(
              entry.key,
              Map<dynamic, dynamic>.from(entry.value as Map),
            );
            entities.add(model.toEntity());
          }
        }
      }
      return entities;
    } catch (e) {
      debugPrint('---> Suppliers: Erro getAll Firebase: $e');
      return [];
    }
  }

  @override
  Future<void> save(SupplierEntity supplier) async {
    final model = SupplierModel.fromEntity(supplier);
    _firebaseDb.addOrUpdate(model.toMap()).catchError((e) {
      debugPrint('---> Suppliers: Erro ao salvar no Firebase em background: $e');
    });
  }

  @override
  Future<void> update(SupplierEntity supplier) async {
    final model = SupplierModel.fromEntity(supplier);
    _firebaseDb.update(supplier.id, model.toMap()).catchError((e) {
      debugPrint('---> Suppliers: Erro ao salvar no Firebase em background: $e');
    });
  }

  @override
  Future<void> delete(String id) async {
    _firebaseDb.delete(id).catchError((e) {
      debugPrint('---> Suppliers: Erro ao deletar no Firebase em background: $e');
    });
  }
}
