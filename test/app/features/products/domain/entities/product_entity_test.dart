import 'package:estoque_pro/app/features/products/domain/entities/product_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProductEntity financial calculations tests', () {
    const product = ProductEntity(
      id: 'p1',
      name: 'Camisa Polo',
      imgUrl: '',
      description: 'Camisa 100% algodão',
      barcode: '1234567890',
      categories: [],
      price: 100.0,
      costPrice: 60.0,
      stock: 10,
      minStock: 2,
    );

    test('unitProfit returns price minus costPrice', () {
      expect(product.unitProfit, 40.0);
    });

    test('marginPercent calculates margin relative to selling price', () {
      expect(product.marginPercent, 40.0);
    });

    test('markupPercent calculates markup relative to cost price', () {
      expect(product.markupPercent, closeTo(66.66, 0.01));
    });

    test('totalCostStock returns costPrice multiplied by stock', () {
      expect(product.totalCostStock, 600.0);
    });

    test('totalSellingStock returns price multiplied by stock', () {
      expect(product.totalSellingStock, 1000.0);
    });

    test('totalProjectedProfit returns unitProfit multiplied by stock', () {
      expect(product.totalProjectedProfit, 400.0);
    });

    test('handles default costPrice of zero gracefully', () {
      const freeCostProduct = ProductEntity(
        id: 'p2',
        name: 'Serviço',
        imgUrl: '',
        description: '',
        categories: [],
        price: 50.0,
        stock: 5,
        minStock: 1,
      );

      expect(freeCostProduct.costPrice, 0.0);
      expect(freeCostProduct.unitProfit, 50.0);
      expect(freeCostProduct.marginPercent, 100.0);
      expect(freeCostProduct.markupPercent, 0.0);
      expect(freeCostProduct.totalCostStock, 0.0);
      expect(freeCostProduct.totalSellingStock, 250.0);
      expect(freeCostProduct.totalProjectedProfit, 250.0);
    });
  });
}
