import 'package:estoque_pro/app/features/suppliers/data/models/supplier_model.dart';
import 'package:estoque_pro/app/features/suppliers/domain/entities/supplier_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SupplierModel', () {
    const supplier = SupplierEntity(
      id: 'sup-1',
      name: 'Distribuidora Central',
      cnpj: '12.345.678/0001-90',
      phone: '(11) 99999-9999',
      isActive: true,
    );

    test('fromMap creates valid SupplierModel', () {
      final map = {
        'name': 'Distribuidora Central',
        'cnpj': '12.345.678/0001-90',
        'phone': '(11) 99999-9999',
        'isActive': true,
      };

      final model = SupplierModel.fromMap('sup-1', map);

      expect(model.id, equals('sup-1'));
      expect(model.name, equals('Distribuidora Central'));
      expect(model.cnpj, equals('12.345.678/0001-90'));
      expect(model.phone, equals('(11) 99999-9999'));
      expect(model.isActive, isTrue);
    });

    test('fromMap handles missing/null values with defaults', () {
      final model = SupplierModel.fromMap('sup-2', {});

      expect(model.id, equals('sup-2'));
      expect(model.name, isEmpty);
      expect(model.cnpj, isNull);
      expect(model.phone, isNull);
      expect(model.isActive, isTrue);
    });

    test('toMap converts model to map representation', () {
      const model = SupplierModel(
        id: 'sup-1',
        name: 'Distribuidora Central',
        cnpj: '12.345.678/0001-90',
        phone: '(11) 99999-9999',
        isActive: true,
      );

      final map = model.toMap();

      expect(map['name'], equals('Distribuidora Central'));
      expect(map['cnpj'], equals('12.345.678/0001-90'));
      expect(map['phone'], equals('(11) 99999-9999'));
      expect(map['isActive'], isTrue);
    });

    test('toEntity converts SupplierModel to SupplierEntity', () {
      const model = SupplierModel(
        id: 'sup-1',
        name: 'Distribuidora Central',
        cnpj: '12.345.678/0001-90',
        phone: '(11) 99999-9999',
        isActive: true,
      );

      final entity = model.toEntity();

      expect(entity.id, equals('sup-1'));
      expect(entity.name, equals('Distribuidora Central'));
      expect(entity.cnpj, equals('12.345.678/0001-90'));
      expect(entity.phone, equals('(11) 99999-9999'));
      expect(entity.isActive, isTrue);
    });

    test('fromEntity converts SupplierEntity to SupplierModel', () {
      final model = SupplierModel.fromEntity(supplier);

      expect(model.id, equals('sup-1'));
      expect(model.name, equals('Distribuidora Central'));
      expect(model.cnpj, equals('12.345.678/0001-90'));
      expect(model.phone, equals('(11) 99999-9999'));
      expect(model.isActive, isTrue);
    });
  });
}
