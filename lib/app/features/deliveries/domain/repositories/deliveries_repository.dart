import 'package:estoque_pro/app/features/deliveries/domain/entities/delivery_entity.dart';
import 'package:estoque_pro/app/features/deliveries/domain/entities/delivery_status.dart';

abstract class DeliveriesRepository {
  Stream<List<DeliveryEntity>> watchAll({int limit = 100});
  Future<void> save(DeliveryEntity delivery);
  Future<void> updateDelivery(DeliveryEntity delivery);
  Future<void> updateStatus(String deliveryId, DeliveryStatus status, {DateTime? deliveredAt});
  Future<void> delete(String deliveryId);
}
