import 'dart:async';

import 'package:estoque_pro/app/core/services/database_service.dart';
import 'package:estoque_pro/app/core/utils/list_extensions.dart';
import 'package:estoque_pro/app/core/utils/result.dart';
import 'package:estoque_pro/app/features/products/data/models/product_history_model.dart';
import 'package:estoque_pro/app/features/products/data/models/product_model.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_entity.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_history_entity.dart';
import 'package:estoque_pro/app/features/products/domain/repositories/products_repository.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

class ProductsRepositoryImpl implements ProductsRepository {
  final DatabaseService<ProductEntity> _databaseService;

  ProductsRepositoryImpl(
    this._databaseService,
  );

  @override
  Stream<List<ProductEntity>> watchAll() {
    return _databaseService
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
          return entities.sortByName((a) => a.name);
        })
        .handleError((e) {
          debugPrint('---> Products: Erro no listener: $e');
        });
  }

  @override
  Future<Result<List<ProductEntity>>> getAll() async {
    try {
      final data = await _databaseService.getOnce();
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
      return Result.success(entities);
    } catch (e, stackTrace) {
      debugPrint('---> Products: Erro getAll: $e');
      return Result.failure(e, stackTrace);
    }
  }

  @override
  Future<Result<void>> save(ProductEntity product) async {
    final model = ProductModel.fromEntity(product);
    try {
      await _databaseService.add(model.toMap());
      return const Result.success(null);
    } catch (e, stackTrace) {
      debugPrint('---> Products: Erro ao salvar: $e');
      return Result.failure(e, stackTrace);
    }
  }

  @override
  Future<Result<void>> update(ProductEntity product) async {
    final model = ProductModel.fromEntity(product);
    try {
      await _databaseService.update(product.id, model.toMap());
      return const Result.success(null);
    } catch (e, stackTrace) {
      debugPrint('---> Products: Erro ao atualizar: $e');
      return Result.failure(e, stackTrace);
    }
  }

  @override
  Future<Result<void>> archive(String id) async {
    try {
      await _databaseService.update(id, {'isActive': false, 'isArchived': true});
      return const Result.success(null);
    } catch (e, stackTrace) {
      debugPrint('---> Products: Erro ao arquivar: $e');
      return Result.failure(e, stackTrace);
    }
  }

  @override
  Future<Result<void>> unarchive(String id) async {
    try {
      await _databaseService.update(id, {'isActive': false, 'isArchived': false});
      return const Result.success(null);
    } catch (e, stackTrace) {
      debugPrint('---> Products: Erro ao desarquivar: $e');
      return Result.failure(e, stackTrace);
    }
  }

  @override
  Future<Result<void>> deletePermanently(String id) async {
    try {
      final updates = {
        'products/$id': null,
        'stock_movements/$id': null,
      };
      await _databaseService.updateMultiple(updates);
      return const Result.success(null);
    } catch (e, stackTrace) {
      debugPrint('---> Products: Erro ao deletar permanentemente: $e');
      return Result.failure(e, stackTrace);
    }
  }

  @override
  Future<Result<void>> adjustStock(String productId, int quantityDiff, ProductHistoryEntity history) async {
    if (productId.trim().isEmpty) {
      return Result.failure(const BusinessRuleFailure(message: 'ID do produto inválido.'));
    }
    if (quantityDiff == 0) {
      return Result.failure(const BusinessRuleFailure(message: 'A quantidade de alteração de estoque não pode ser zero.'));
    }

    try {
      final pushRef = _databaseService.ref.root.child('stock_movements').child(productId).push();
      final historyModel = ProductHistoryModel.fromEntity(history);

      final updates = {
        'products/$productId/stock': ServerValue.increment(quantityDiff),
        'products/$productId/updatedAt': ServerValue.timestamp,
        'stock_movements/$productId/${pushRef.key}': historyModel.toMap(),
      };

      await _databaseService.updateMultiple(updates);
      return const Result.success(null);
    } catch (e, stackTrace) {
      debugPrint('---> Products: Erro ao ajustar estoque atômicamente: $e');
      return Result.failure(e, stackTrace);
    }
  }

  @override
  Stream<List<ProductHistoryEntity>> watchHistory(String productId, {int limit = 20}) {
    return _databaseService.ref.root
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
  Future<Result<bool>> checkBarcodeExists(String barcode, {String? ignoreId}) async {
    final trimmed = barcode.trim();
    if (trimmed.isEmpty) return const Result.success(false);
    try {
      final snapshot = await _databaseService.ref
          .orderByChild('barcode')
          .equalTo(trimmed)
          .get()
          .timeout(const Duration(milliseconds: 800));
      if (!snapshot.exists) return const Result.success(false);

      final data = snapshot.value as Map;
      if (ignoreId != null) {
        // Se houver apenas 1 produto com esse barcode e for ele mesmo, não é duplicidade.
        if (data.length == 1 && data.keys.first == ignoreId) {
          return const Result.success(false);
        }
      }
      return const Result.success(true);
    } catch (e, stackTrace) {
      debugPrint('---> Products: Erro ao checar duplicidade de barcode: $e');
      return Result.failure(e, stackTrace);
    }
  }
}
