import 'package:estoque_pro/app/features/products/domain/entities/product_entity.dart';
import 'package:estoque_pro/app/features/products/presentation/widgets/product_financial_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ProductFinancialCard renders cost price, selling price, unit profit and stock values', (tester) async {
    const product = ProductEntity(
      id: 'p1',
      name: 'Camisa Polo',
      imgUrl: '',
      description: '',
      barcode: '',
      categories: [],
      price: 100.0,
      costPrice: 60.0,
      stock: 10,
      minStock: 2,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ProductFinancialCard(product: product),
          ),
        ),
      ),
    );

    expect(find.text('Rentabilidade & Estoque'), findsOneWidget);
    expect(find.text('Preço de Custo (Unitário)'), findsOneWidget);
    expect(find.text('R\$ 60,00'), findsOneWidget);
    expect(find.text('Preço de Venda (Unitário)'), findsOneWidget);
    expect(find.text('R\$ 100,00'), findsOneWidget);
    expect(find.text('Lucro Unitário'), findsOneWidget);
    expect(find.text('R\$ 40,00 (40.0%)'), findsOneWidget);

    expect(find.text('Total em Estoque (a Custo)'), findsOneWidget);
    expect(find.text('R\$ 600,00'), findsOneWidget);
    expect(find.text('Total em Estoque (a Venda)'), findsOneWidget);
    expect(find.text('R\$ 1.000,00'), findsOneWidget);
    expect(find.text('Lucro Previsto no Estoque'), findsOneWidget);
    expect(find.text('R\$ 400,00'), findsOneWidget);
  });
}
