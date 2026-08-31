import 'dart:async';

import 'package:estoque_pro/app/core/services/database_service.dart';
import 'package:estoque_pro/app/core/utils/list_extensions.dart';
import 'package:estoque_pro/app/core/utils/result.dart';
import 'package:estoque_pro/app/features/suppliers/data/models/supplier_model.dart';
import 'package:estoque_pro/app/features/suppliers/domain/entities/supplier_entity.dart';
import 'package:estoque_pro/app/features/suppliers/domain/repositories/suppliers_repository.dart';
import 'package:flutter/foundation.dart';

class SuppliersRepositoryImpl implements SuppliersRepository {
  final DatabaseService<SupplierEntity> _databaseService;

  SuppliersRepositoryImpl(
    this._databaseService,
  );

  @override
  Stream<List<SupplierEntity>> watchAll() {
    return _databaseService
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
          return entities.sortByName((a) => a.name);
        })
        .handleError((e) {
          debugPrint('---> Suppliers: Erro no listener: $e');
        });
  }

  @override
  Future<Result<List<SupplierEntity>>> getAll() async {
    try {
      final data = await _databaseService.getOnce();
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
      return Result.success(entities);
    } catch (e, stackTrace) {
      debugPrint('---> Suppliers: Erro getAll: $e');
      return Result.failure(e, stackTrace);
    }
  }

  @override
  Future<Result<void>> save(SupplierEntity supplier) async {
    final model = SupplierModel.fromEntity(supplier);
    try {
      await _databaseService.add(model.toMap());
      return const Result.success(null);
    } catch (e, stackTrace) {
      debugPrint('---> Suppliers: Erro ao salvar: $e');
      return Result.failure(e, stackTrace);
    }
  }

  @override
  Future<Result<void>> update(SupplierEntity supplier) async {
    final model = SupplierModel.fromEntity(supplier);
    try {
      await _databaseService.update(supplier.id, model.toMap());
      return const Result.success(null);
    } catch (e, stackTrace) {
      debugPrint('---> Suppliers: Erro ao atualizar: $e');
      return Result.failure(e, stackTrace);
    }
  }

  @override
  Future<Result<void>> delete(String id) async {
    try {
      await _databaseService.delete(id);
      return const Result.success(null);
    } catch (e, stackTrace) {
      debugPrint('---> Suppliers: Erro ao deletar: $e');
      return Result.failure(e, stackTrace);
    }
  }
}
