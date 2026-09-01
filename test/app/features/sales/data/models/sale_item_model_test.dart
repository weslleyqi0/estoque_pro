import 'package:estoque_pro/app/features/sales/data/models/sale_item_model.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_item_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SaleItemModel', () {
    const item = SaleItemEntity(
      productId: 'prod-1',
      productName: 'Refrigerante 2L',
      productImgUrl: 'http://img.png',
      unitPrice: 8.50,
      quantity: 2,
    );

    test('fromMap and toMap serialize accurately', () {
      final model = SaleItemModel.fromMap({
        'product_id': 'prod-1',
        'product_name': 'Refrigerante 2L',
        'product_img_url': 'http://img.png',
        'unit_price': 8.50,
        'quantity': 2,
      });

      expect(model.productId, equals('prod-1'));
      expect(model.productName, equals('Refrigerante 2L'));
      expect(model.unitPrice, equals(8.50));
      expect(model.quantity, equals(2));

      final map = model.toMap();
      expect(map['product_id'], equals('prod-1'));
      expect(map['product_name'], equals('Refrigerante 2L'));
      expect(map['unit_price'], equals(8.50));
      expect(map['quantity'], equals(2));
    });

    test('toEntity and fromEntity convert accurately', () {
      final model = SaleItemModel.fromEntity(item);
      final entity = model.toEntity();

      expect(entity.productId, equals('prod-1'));
      expect(entity.productName, equals('Refrigerante 2L'));
      expect(entity.unitPrice, equals(8.50));
      expect(entity.quantity, equals(2));
    });
  });
}
