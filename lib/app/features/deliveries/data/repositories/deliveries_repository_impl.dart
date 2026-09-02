import 'package:estoque_pro/app/core/services/database_service.dart';
import 'package:estoque_pro/app/core/utils/result.dart';
import 'package:estoque_pro/app/features/deliveries/data/models/delivery_model.dart';
import 'package:estoque_pro/app/features/deliveries/domain/entities/delivery_entity.dart';
import 'package:estoque_pro/app/features/deliveries/domain/entities/delivery_status.dart';
import 'package:estoque_pro/app/features/deliveries/domain/repositories/deliveries_repository.dart';
import 'package:flutter/foundation.dart';

class DeliveriesRepositoryImpl implements DeliveriesRepository {
  final DatabaseService<DeliveryEntity> _databaseService;

  DeliveriesRepositoryImpl(this._databaseService);

  @override
  Stream<List<DeliveryEntity>> watchAll({int limit = 100}) {
    return _databaseService
        .listenOrdered(
          orderByChild: 'created_at',
          limitToLast: limit,
        )
        .map((data) {
          final List<DeliveryEntity> deliveries = [];
          if (data != null) {
            for (final entry in data.entries) {
              if (entry.value is Map) {
                try {
                  final model = DeliveryModel.fromMap(
                    entry.key.toString(),
                    Map<dynamic, dynamic>.from(entry.value as Map),
                  );
                  deliveries.add(model.toEntity());
                } catch (e, stack) {
                  debugPrint('---> Deliveries: Erro ao parsear entrega ${entry.key}: $e\n$stack');
                }
              }
            }
          }
          // Sort by scheduledAt ascending (or createdAt descending)
          return deliveries..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
        })
        .handleError((e) {
          debugPrint('---> Deliveries: Erro no listener: $e');
        });
  }

  @override
  Future<Result<void>> save(DeliveryEntity delivery) async {
    try {
      final pushKey = _databaseService.pushKey();
      final deliveryId = delivery.id.isNotEmpty ? delivery.id : pushKey;

      final finalDelivery = delivery.copyWith(id: deliveryId);
      final deliveryModel = DeliveryModel.fromEntity(finalDelivery);
      final deliveryModelMap = deliveryModel.toMap();
      deliveryModelMap['created_at'] = _databaseService.serverTimestamp;
      deliveryModelMap['updated_at'] = _databaseService.serverTimestamp;

      await _databaseService.update(deliveryId, deliveryModelMap);
      return const Result.success(null);
    } catch (e, stackTrace) {
      debugPrint('---> Deliveries: Erro ao salvar entrega: $e');
      return Result.failure(e, stackTrace);
    }
  }

  @override
  Future<Result<void>> updateDelivery(DeliveryEntity delivery) async {
    try {
      final deliveryModel = DeliveryModel.fromEntity(
        delivery.copyWith(updatedAt: DateTime.now()),
      );
      final deliveryModelMap = deliveryModel.toMap();
      deliveryModelMap['updated_at'] = _databaseService.serverTimestamp;

      await _databaseService.update(delivery.id, deliveryModelMap);
      return const Result.success(null);
    } catch (e, stackTrace) {
      debugPrint('---> Deliveries: Erro ao atualizar entrega: $e');
      return Result.failure(e, stackTrace);
    }
  }

  @override
  Future<Result<void>> updateStatus(
    String deliveryId,
    DeliveryStatus status, {
    DateTime? deliveredAt,
  }) async {
    try {
      final Map<String, dynamic> updates = {
        'status': status.value,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (deliveredAt != null) {
        updates['delivered_at'] = deliveredAt.toIso8601String();
      } else if (status == DeliveryStatus.completed) {
        updates['delivered_at'] = DateTime.now().toIso8601String();
      }

      await _databaseService.update(deliveryId, updates);
      return const Result.success(null);
    } catch (e, stackTrace) {
      debugPrint('---> Deliveries: Erro ao atualizar status da entrega: $e');
      return Result.failure(e, stackTrace);
    }
  }

  @override
  Future<Result<void>> delete(String deliveryId) async {
    try {
      await _databaseService.delete(deliveryId);
      return const Result.success(null);
    } catch (e, stackTrace) {
      debugPrint('---> Deliveries: Erro ao deletar entrega: $e');
      return Result.failure(e, stackTrace);
    }
  }

  @override
  Future<Result<DeliveryEntity?>> getDeliveryBySaleId(String saleId, [String? saleNumber]) async {
    try {
      if (saleId.isNotEmpty) {
        final data = await _databaseService.queryOnce(
          orderByChild: 'sale_id',
          equalTo: saleId,
          limitToLast: 1,
        );
        if (data != null && data.isNotEmpty) {
          final entry = data.entries.first;
          if (entry.value is Map) {
            final model = DeliveryModel.fromMap(
              entry.key.toString(),
              Map<dynamic, dynamic>.from(entry.value as Map),
            );
            return Result.success(model.toEntity());
          }
        }
      }

      if (saleNumber != null && saleNumber.isNotEmpty) {
        final data = await _databaseService.queryOnce(
          orderByChild: 'sale_number',
          equalTo: saleNumber,
          limitToLast: 1,
        );
        if (data != null && data.isNotEmpty) {
          final entry = data.entries.first;
          if (entry.value is Map) {
            final model = DeliveryModel.fromMap(
              entry.key.toString(),
              Map<dynamic, dynamic>.from(entry.value as Map),
            );
            return Result.success(model.toEntity());
          }
        }
      }

      return const Result.success(null);
    } catch (e, stackTrace) {
      debugPrint('---> Deliveries: Erro ao buscar entrega por venda: $e');
      return Result.failure(e, stackTrace);
    }
  }

  @override
  Future<Result<void>> cancelDeliveryForSale(String saleId, [String? saleNumber]) async {
    try {
      final List<DeliveryEntity> toCancel = [];

      if (saleId.isNotEmpty) {
        final data = await _databaseService.queryOnce(
          orderByChild: 'sale_id',
          equalTo: saleId,
        );
        if (data != null && data.isNotEmpty) {
          for (final entry in data.entries) {
            if (entry.value is Map) {
              final model = DeliveryModel.fromMap(
                entry.key.toString(),
                Map<dynamic, dynamic>.from(entry.value as Map),
              );
              toCancel.add(model.toEntity());
            }
          }
        }
      }

      if (toCancel.isEmpty && saleNumber != null && saleNumber.isNotEmpty) {
        final data = await _databaseService.queryOnce(
          orderByChild: 'sale_number',
          equalTo: saleNumber,
        );
        if (data != null && data.isNotEmpty) {
          for (final entry in data.entries) {
            if (entry.value is Map) {
              final model = DeliveryModel.fromMap(
                entry.key.toString(),
                Map<dynamic, dynamic>.from(entry.value as Map),
              );
              toCancel.add(model.toEntity());
            }
          }
        }
      }

      for (final delivery in toCancel) {
        if (delivery.status != DeliveryStatus.cancelled) {
          await updateStatus(delivery.id, DeliveryStatus.cancelled);
        }
      }

      return const Result.success(null);
    } catch (e, stackTrace) {
      debugPrint('---> Deliveries: Erro ao cancelar entrega da venda: $e');
      return Result.failure(e, stackTrace);
    }
  }
}
