import 'dart:async';

import 'package:estoque_pro/app/core/services/database_service.dart';
import 'package:estoque_pro/app/core/utils/list_extensions.dart';
import 'package:estoque_pro/app/features/categories/data/models/category_model.dart';
import 'package:estoque_pro/app/features/categories/domain/entities/category_entity.dart';
import 'package:estoque_pro/app/features/categories/domain/repositories/categories_repository.dart';
import 'package:flutter/foundation.dart';

class CategoriesRepositoryImpl implements CategoriesRepository {
  final DatabaseService<CategoryEntity> _databaseService;

  CategoriesRepositoryImpl(
    this._databaseService,
  );

  @override
  Stream<List<CategoryEntity>> watchAll() {
    return _databaseService
        .listen()
        .map((data) {
          final List<CategoryEntity> entities = [];
          if (data != null) {
            for (final entry in data.entries) {
              if (entry.value is Map) {
                final model = CategoryModel.fromMap(
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
          debugPrint('---> Categories: Erro no listener: $e');
        });
  }

  @override
  Future<List<CategoryEntity>> getAll() async {
    try {
      final data = await _databaseService.getOnce();
      final List<CategoryEntity> entities = [];
      if (data != null) {
        for (final entry in data.entries) {
          if (entry.value is Map) {
            final model = CategoryModel.fromMap(
              entry.key,
              Map<dynamic, dynamic>.from(entry.value as Map),
            );
            entities.add(model.toEntity());
          }
        }
      }
      return entities;
    } catch (e) {
      debugPrint('---> Categories: Erro getAll: $e');
      return [];
    }
  }

  @override
  Future<void> save(CategoryEntity category) async {
    final model = CategoryModel.fromEntity(category);
    try {
      await _databaseService.add(model.toMap());
    } catch (e) {
      debugPrint('---> Categories: Erro ao salvar: $e');
      rethrow;
    }
  }

  @override
  Future<void> update(CategoryEntity category) async {
    final model = CategoryModel.fromEntity(category);
    try {
      await _databaseService.update(category.id, model.toMap());
    } catch (e) {
      debugPrint('---> Categories: Erro ao atualizar: $e');
      rethrow;
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _databaseService.delete(id);
    } catch (e) {
      debugPrint('---> Categories: Erro ao deletar: $e');
      rethrow;
    }
  }
}
