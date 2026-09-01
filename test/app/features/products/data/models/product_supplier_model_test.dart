import 'package:estoque_pro/app/features/products/data/models/product_supplier_model.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_supplier_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProductSupplierModel', () {
    const supplier = ProductSupplierEntity(id: 'sup-1', name: 'Fornecedor A');

    test('fromMap and toMap serialize correctly', () {
      final model = ProductSupplierModel.fromMap({'id': 'sup-1', 'name': 'Fornecedor A'});
      expect(model.id, equals('sup-1'));
      expect(model.name, equals('Fornecedor A'));

      final map = model.toMap();
      expect(map['id'], equals('sup-1'));
      expect(map['name'], equals('Fornecedor A'));
    });

    test('toEntity and fromEntity convert accurately', () {
      final model = ProductSupplierModel.fromEntity(supplier);
      final entity = model.toEntity();

      expect(entity.id, equals('sup-1'));
      expect(entity.name, equals('Fornecedor A'));
    });
  });
}
