import 'package:estoque_pro/app/core/services/database_service.dart';
import 'package:estoque_pro/app/core/utils/result.dart';
import 'package:estoque_pro/app/features/deliveries/data/models/delivery_model.dart';
import 'package:estoque_pro/app/features/deliveries/domain/entities/delivery_entity.dart';
import 'package:estoque_pro/app/features/deliveries/domain/entities/delivery_status.dart';
import 'package:estoque_pro/app/features/deliveries/domain/repositories/deliveries_repository.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

class DeliveriesRepositoryImpl implements DeliveriesRepository {
  final DatabaseService<DeliveryEntity> _databaseService;

  DeliveriesRepositoryImpl(this._databaseService);

  @override
  Stream<List<DeliveryEntity>> watchAll({int limit = 100}) {
    return _databaseService.ref
        .orderByChild('created_at')
        .limitToLast(limit)
        .onValue
        .map((event) {
          final List<DeliveryEntity> deliveries = [];
          final value = event.snapshot.value;
          if (value is Map) {
            for (final entry in value.entries) {
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
      final pushRef = _databaseService.ref.push();
      final deliveryId = delivery.id.isNotEmpty ? delivery.id : pushRef.key!;

      final finalDelivery = delivery.copyWith(id: deliveryId);
      final deliveryModel = DeliveryModel.fromEntity(finalDelivery);

      final Map<String, dynamic> updates = {};
      updates['deliveries/$deliveryId'] = deliveryModel.toMap();

      await _databaseService.updateMultiple(updates);
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

      final Map<String, dynamic> updates = {};
      updates['deliveries/${delivery.id}'] = deliveryModel.toMap();

      await _databaseService.updateMultiple(updates);
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
        'updated_at': ServerValue.timestamp,
      };

      if (deliveredAt != null) {
        updates['delivered_at'] = deliveredAt.toIso8601String();
      } else if (status == DeliveryStatus.completed) {
        updates['delivered_at'] = DateTime.now().toIso8601String();
      }

      await _databaseService.ref.child(deliveryId).update(updates);
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
}
