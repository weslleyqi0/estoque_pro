import 'package:estoque_pro/app/features/home/domain/entities/home_shortcut_type.dart';
import 'package:estoque_pro/app/features/settings/presentation/widgets/home_shortcut_reorder_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('HomeShortcutReorderTile renders title, subtitle and Gestor badge when managerOnly', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ReorderableListView(
            onReorderItem: (oldIdx, newIdx) {},
            children: const [
              HomeShortcutReorderTile(
                key: ValueKey('reports'),
                item: HomeShortcutType.reports,
                index: 0,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Relatórios'), findsOneWidget);
    expect(find.text('Análise completa'), findsOneWidget);
    expect(find.text('Gestor'), findsOneWidget);
  });

  testWidgets('HomeShortcutReorderTile does not show Gestor badge for seller shortcuts', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ReorderableListView(
            onReorderItem: (oldIdx, newIdx) {},
            children: const [
              HomeShortcutReorderTile(
                key: ValueKey('products'),
                item: HomeShortcutType.products,
                index: 0,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Produtos'), findsOneWidget);
    expect(find.text('Gerenciar Catalogo'), findsOneWidget);
    expect(find.text('Gestor'), findsNothing);
  });
}
