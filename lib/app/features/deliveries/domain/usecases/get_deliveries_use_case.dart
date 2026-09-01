import 'package:estoque_pro/app/features/deliveries/domain/entities/delivery_entity.dart';
import 'package:estoque_pro/app/features/deliveries/domain/repositories/deliveries_repository.dart';

class GetDeliveriesUseCase {
  final DeliveriesRepository _repository;

  const GetDeliveriesUseCase(this._repository);

  Stream<List<DeliveryEntity>> watchAll({int limit = 100}) {
    return _repository.watchAll(limit: limit);
  }
}
