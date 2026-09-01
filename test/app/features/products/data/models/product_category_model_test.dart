import 'package:estoque_pro/app/features/products/data/models/product_category_model.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_category_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProductCategoryModel', () {
    const category = ProductCategoryEntity(id: 'cat-1', name: 'Alimentos');

    test('fromMap and toMap serialize correctly', () {
      final model = ProductCategoryModel.fromMap({'id': 'cat-1', 'name': 'Alimentos'});
      expect(model.id, equals('cat-1'));
      expect(model.name, equals('Alimentos'));

      final map = model.toMap();
      expect(map['id'], equals('cat-1'));
      expect(map['name'], equals('Alimentos'));
    });

    test('toEntity and fromEntity convert accurately', () {
      final model = ProductCategoryModel.fromEntity(category);
      final entity = model.toEntity();

      expect(entity.id, equals('cat-1'));
      expect(entity.name, equals('Alimentos'));
    });
  });
}
