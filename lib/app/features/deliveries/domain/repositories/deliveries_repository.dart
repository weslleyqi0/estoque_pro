import 'package:estoque_pro/app/core/utils/result.dart';
import 'package:estoque_pro/app/features/deliveries/domain/entities/delivery_entity.dart';
import 'package:estoque_pro/app/features/deliveries/domain/entities/delivery_status.dart';

abstract class DeliveriesRepository {
  Stream<List<DeliveryEntity>> watchAll({int limit = 100});
  Future<Result<void>> save(DeliveryEntity delivery);
  Future<Result<void>> updateDelivery(DeliveryEntity delivery);
  Future<Result<void>> updateStatus(String deliveryId, DeliveryStatus status, {DateTime? deliveredAt});
  Future<Result<void>> delete(String deliveryId);
}
