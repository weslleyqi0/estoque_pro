import 'package:estoque_pro/app/core/services/firebase_database_service.dart';
import 'package:estoque_pro/app/features/deliveries/data/models/delivery_model.dart';
import 'package:estoque_pro/app/features/deliveries/domain/entities/delivery_entity.dart';
import 'package:estoque_pro/app/features/deliveries/domain/entities/delivery_status.dart';
import 'package:estoque_pro/app/features/deliveries/domain/repositories/deliveries_repository.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

class DeliveriesRepositoryImpl implements DeliveriesRepository {
  final FirebaseDatabaseService<DeliveryEntity> _firebaseDb;

  DeliveriesRepositoryImpl(this._firebaseDb);

  @override
  Stream<List<DeliveryEntity>> watchAll({int limit = 100}) {
    return _firebaseDb.ref
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
          debugPrint('---> Deliveries: Erro no listener Firebase: $e');
        });
  }

  @override
  Future<void> save(DeliveryEntity delivery) async {
    try {
      final pushRef = _firebaseDb.ref.push();
      final deliveryId = delivery.id.isNotEmpty ? delivery.id : pushRef.key!;

      final finalDelivery = delivery.copyWith(id: deliveryId);
      final deliveryModel = DeliveryModel.fromEntity(finalDelivery);

      final Map<String, dynamic> updates = {};
      updates['deliveries/$deliveryId'] = deliveryModel.toMap();

      await _firebaseDb.updateMultiple(updates);
    } catch (e) {
      debugPrint('---> Deliveries: Erro ao salvar entrega: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateDelivery(DeliveryEntity delivery) async {
    try {
      final deliveryModel = DeliveryModel.fromEntity(
        delivery.copyWith(updatedAt: DateTime.now()),
      );

      final Map<String, dynamic> updates = {};
      updates['deliveries/${delivery.id}'] = deliveryModel.toMap();

      await _firebaseDb.updateMultiple(updates);
    } catch (e) {
      debugPrint('---> Deliveries: Erro ao atualizar entrega: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateStatus(
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

      await _firebaseDb.ref.child(deliveryId).update(updates);
    } catch (e) {
      debugPrint('---> Deliveries: Erro ao atualizar status da entrega: $e');
      rethrow;
    }
  }

  @override
  Future<void> delete(String deliveryId) async {
    try {
      await _firebaseDb.delete(deliveryId);
    } catch (e) {
      debugPrint('---> Deliveries: Erro ao deletar entrega: $e');
      rethrow;
    }
  }
}
