import 'dart:async';

import 'package:estoque_pro/app/core/services/firebase_database_service.dart';
import 'package:estoque_pro/app/features/categories/data/models/category_model.dart';
import 'package:estoque_pro/app/features/categories/domain/entities/category_entity.dart';
import 'package:estoque_pro/app/features/categories/domain/repositories/categories_repository.dart';
import 'package:flutter/foundation.dart';

class CategoriesRepositoryImpl implements CategoriesRepository {
  final FirebaseDatabaseService _firebaseDb;

  CategoriesRepositoryImpl(
    this._firebaseDb,
  );

  @override
  Stream<List<CategoryEntity>> watchAll() {
    return _firebaseDb
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
          return entities..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        })
        .handleError((e) {
          debugPrint('---> Categories: Erro no listener Firebase: $e');
        });
  }

  @override
  Future<List<CategoryEntity>> getAll() async {
    try {
      final data = await _firebaseDb.getOnce();
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
      debugPrint('---> Categories: Erro getAll Firebase: $e');
      return [];
    }
  }

  @override
  Future<void> save(CategoryEntity category) async {
    final model = CategoryModel.fromEntity(category);
    try {
      await _firebaseDb.add(model.toMap());
    } catch (e) {
      debugPrint('---> Categories: Erro ao salvar no Firebase: $e');
      rethrow;
    }
  }

  @override
  Future<void> update(CategoryEntity category) async {
    final model = CategoryModel.fromEntity(category);
    try {
      await _firebaseDb.update(category.id, model.toMap());
    } catch (e) {
      debugPrint('---> Categories: Erro ao atualizar no Firebase: $e');
      rethrow;
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _firebaseDb.delete(id);
    } catch (e) {
      debugPrint('---> Categories: Erro ao deletar no Firebase: $e');
      rethrow;
    }
  }
}
