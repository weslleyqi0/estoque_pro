import 'dart:async';

import 'package:estoque_pro/app/core/services/firebase_database_service.dart';
import 'package:estoque_pro/app/features/products/data/models/product_model.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_entity.dart';
import 'package:estoque_pro/app/features/products/domain/repositories/products_repository.dart';
import 'package:flutter/foundation.dart';

class ProductsRepositoryImpl implements ProductsRepository {
  final FirebaseDatabaseService _firebaseDb;

  ProductsRepositoryImpl(
    this._firebaseDb,
  );

  @override
  Stream<List<ProductEntity>> watchAll() {
    return _firebaseDb
        .listen()
        .map((data) {
          final List<ProductEntity> entities = [];
          if (data != null) {
            for (final entry in data.entries) {
              if (entry.value is Map) {
                final model = ProductModel.fromMap(
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
          debugPrint('---> Products: Erro no listener Firebase: $e');
        });
  }

  @override
  Future<List<ProductEntity>> getAll() async {
    try {
      final data = await _firebaseDb.getOnce();
      final List<ProductEntity> entities = [];
      if (data != null) {
        for (final entry in data.entries) {
          if (entry.value is Map) {
            final model = ProductModel.fromMap(
              entry.key,
              Map<dynamic, dynamic>.from(entry.value as Map),
            );
            entities.add(model.toEntity());
          }
        }
      }
      return entities;
    } catch (e) {
      debugPrint('---> Products: Erro getAll Firebase: $e');
      return [];
    }
  }

  @override
  Future<void> save(ProductEntity product) async {
    final model = ProductModel.fromEntity(product);
    try {
      await _firebaseDb.addOrUpdate(model.toMap());
    } catch (e) {
      debugPrint('---> Products: Erro ao salvar no Firebase: $e');
      rethrow;
    }
  }

  @override
  Future<void> update(ProductEntity product) async {
    final model = ProductModel.fromEntity(product);
    try {
      await _firebaseDb.update(product.id, model.toMap());
    } catch (e) {
      debugPrint('---> Products: Erro ao atualizar no Firebase: $e');
      rethrow;
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _firebaseDb.delete(id);
    } catch (e) {
      debugPrint('---> Products: Erro ao deletar no Firebase: $e');
      rethrow;
    }
  }
}
