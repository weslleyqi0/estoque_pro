import 'dart:async';

import 'package:estoque_pro/app/core/services/firebase_database_service.dart';
import 'package:estoque_pro/app/features/products/data/models/product_history_model.dart';
import 'package:estoque_pro/app/features/products/data/models/product_model.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_entity.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_history_entity.dart';
import 'package:estoque_pro/app/features/products/domain/repositories/products_repository.dart';
import 'package:firebase_database/firebase_database.dart';
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
      await _firebaseDb.add(model.toMap());
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
  Future<void> archive(String id) async {
    try {
      await _firebaseDb.update(id, {'isActive': false});
    } catch (e) {
      debugPrint('---> Products: Erro ao arquivar no Firebase: $e');
      rethrow;
    }
  }

  @override
  Future<void> unarchive(String id) async {
    try {
      await _firebaseDb.update(id, {'isActive': true});
    } catch (e) {
      debugPrint('---> Products: Erro ao desarquivar no Firebase: $e');
      rethrow;
    }
  }

  @override
  Future<void> deletePermanently(String id) async {
    try {
      final updates = {
        'products/$id': null,
        'stock_movements/$id': null,
      };
      await _firebaseDb.updateMultiple(updates);
    } catch (e) {
      debugPrint('---> Products: Erro ao deletar permanentemente no Firebase: $e');
      rethrow;
    }
  }

  @override
  Future<void> adjustStock(String productId, int quantityDiff, ProductHistoryEntity history) async {
    if (productId.trim().isEmpty) {
      throw Exception('ID do produto inválido.');
    }
    if (quantityDiff == 0) {
      throw Exception('A quantidade de alteração de estoque não pode ser zero.');
    }

    try {
      final pushRef = _firebaseDb.ref.root.child('stock_movements').child(productId).push();
      final historyModel = ProductHistoryModel.fromEntity(history);

      final updates = {
        'products/$productId/stock': ServerValue.increment(quantityDiff),
        'products/$productId/updatedAt': ServerValue.timestamp,
        'stock_movements/$productId/${pushRef.key}': historyModel.toMap(),
      };

      await _firebaseDb.updateMultiple(updates);
    } catch (e) {
      debugPrint('---> Products: Erro ao ajustar estoque atômicamente no Firebase: $e');
      rethrow;
    }
  }

  @override
  Stream<List<ProductHistoryEntity>> watchHistory(String productId, {int limit = 20}) {
    return _firebaseDb.ref.root
        .child('stock_movements')
        .child(productId)
        .orderByChild('date')
        .limitToLast(limit)
        .onValue
        .map((event) {
          final List<ProductHistoryEntity> history = [];
          final value = event.snapshot.value;
          if (value is Map) {
            for (final entry in value.entries) {
              if (entry.value is Map) {
                final model = ProductHistoryModel.fromMap(
                  Map<dynamic, dynamic>.from(entry.value as Map),
                );
                history.add(model.toEntity());
              }
            }
          }
          return history..sort((a, b) => b.date.compareTo(a.date));
        })
        .handleError((e) {
          debugPrint('---> Products: Erro no listener de history: $e');
        });
  }

  @override
  Future<bool> checkBarcodeExists(String barcode, {String? ignoreId}) async {
    final trimmed = barcode.trim();
    if (trimmed.isEmpty) return false;
    try {
      final snapshot = await _firebaseDb.ref
          .orderByChild('barcode')
          .equalTo(trimmed)
          .get()
          .timeout(const Duration(milliseconds: 800));
      if (!snapshot.exists) return false;

      final data = snapshot.value as Map;
      if (ignoreId != null) {
        // Se houver apenas 1 produto com esse barcode e for ele mesmo, não é duplicidade.
        if (data.length == 1 && data.keys.first == ignoreId) {
          return false;
        }
      }
      return true;
    } catch (e) {
      debugPrint('---> Products: Erro ao checar duplicidade de barcode: $e');
      return false; // Falha segura
    }
  }
}
