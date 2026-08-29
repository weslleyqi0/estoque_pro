import 'package:estoque_pro/app/features/products/data/models/product_model.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProductModel tests with costPrice', () {
    const entity = ProductEntity(
      id: 'p1',
      name: 'Camisa Polo',
      imgUrl: 'https://example.com/img.png',
      description: 'Camisa azul',
      barcode: '7891234567890',
      categories: [],
      price: 120.0,
      costPrice: 70.0,
      stock: 15,
      minStock: 3,
    );

    test('toEntity and fromEntity convert costPrice properly', () {
      final model = ProductModel.fromEntity(entity);
      expect(model.costPrice, 70.0);

      final convertedEntity = model.toEntity();
      expect(convertedEntity.costPrice, 70.0);
      expect(convertedEntity.price, 120.0);
    });

    test('toMap and fromMap serialize and deserialize costPrice', () {
      final map = {
        'name': 'Camisa Polo',
        'imgUrl': 'https://example.com/img.png',
        'description': 'Camisa azul',
        'barcode': '7891234567890',
        'categories': <dynamic>[],
        'price': 120.0,
        'costPrice': 70.0,
        'stock': 15,
        'minStock': 3,
        'isActive': true,
        'isArchived': false,
      };

      final model = ProductModel.fromMap('p1', map);
      expect(model.costPrice, 70.0);
      expect(model.price, 120.0);

      final generatedMap = model.toMap();
      expect(generatedMap['costPrice'], 70.0);
      expect(generatedMap['price'], 120.0);
    });

    test('fromMap sets costPrice to 0.0 when missing from database', () {
      final legacyMap = {
        'name': 'Produto Antigo',
        'imgUrl': '',
        'description': '',
        'barcode': '',
        'categories': <dynamic>[],
        'price': 50.0,
        'stock': 10,
        'minStock': 2,
        'isActive': true,
        'isArchived': false,
      };

      final model = ProductModel.fromMap('p2', legacyMap);
      expect(model.costPrice, 0.0);
    });
  });
}
