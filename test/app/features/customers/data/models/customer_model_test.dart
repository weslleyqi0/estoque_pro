import 'package:estoque_pro/app/features/customers/data/models/customer_model.dart';
import 'package:estoque_pro/app/features/customers/domain/entities/customer_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CustomerModel & CustomerEntity Tests', () {
    const testEntity = CustomerEntity(
      id: 'cust_1',
      name: 'João Silva',
      address: 'Rua Flores 123',
      cpf: '12345678901',
      phone: '11999999999',
      isActive: true,
    );

    test('toEntity converts Model to Entity accurately', () {
      const model = CustomerModel(
        id: 'cust_1',
        name: 'João Silva',
        address: 'Rua Flores 123',
        cpf: '12345678901',
        phone: '11999999999',
        isActive: true,
      );

      final entity = model.toEntity();
      expect(entity, equals(testEntity));
    });

    test('fromEntity converts Entity to Model accurately', () {
      final model = CustomerModel.fromEntity(testEntity);
      expect(model.id, 'cust_1');
      expect(model.name, 'João Silva');
      expect(model.address, 'Rua Flores 123');
      expect(model.cpf, '12345678901');
      expect(model.phone, '11999999999');
      expect(model.isActive, true);
    });

    test('fromMap parses map correctly with defaults', () {
      final map = {
        'name': 'Maria Santos',
        'is_active': false,
      };

      final model = CustomerModel.fromMap('cust_2', map);
      expect(model.id, 'cust_2');
      expect(model.name, 'Maria Santos');
      expect(model.address, isNull);
      expect(model.cpf, isNull);
      expect(model.phone, isNull);
      expect(model.isActive, false);
    });

    test('toMap converts to map correctly', () {
      final map = CustomerModel.fromEntity(testEntity).toMap();
      expect(map['name'], 'João Silva');
      expect(map['address'], 'Rua Flores 123');
      expect(map['cpf'], '12345678901');
      expect(map['phone'], '11999999999');
      expect(map['is_active'], true);
    });
  });
}
