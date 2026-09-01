import 'package:estoque_pro/app/features/sales/domain/entities/sale_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/repositories/sales_repository.dart';

class GetSalesUseCase {
  final SalesRepository _repository;

  const GetSalesUseCase(this._repository);

  Stream<List<SaleEntity>> watchAll({int limit = 50}) {
    return _repository.watchAll(limit: limit);
  }
}
