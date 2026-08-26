import 'package:estoque_pro/app/features/home/domain/entities/home_shortcut_type.dart';
import 'package:estoque_pro/app/features/home/presentation/widgets/home_shortcut_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('HomeShortcutButton renders title, subtitle and badge for Products with lowStock', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: HomeShortcutButton(
            type: HomeShortcutType.products,
            lowStockCount: 5,
          ),
        ),
      ),
    );

    expect(find.text('Produtos'), findsOneWidget);
    expect(find.text('Gerenciar Catalogo'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
  });

  testWidgets('HomeShortcutButton triggers onProductsTap callback when clicked', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HomeShortcutButton(
            type: HomeShortcutType.products,
            onProductsTap: () => tapped = true,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Produtos'));
    expect(tapped, isTrue);
  });
}
