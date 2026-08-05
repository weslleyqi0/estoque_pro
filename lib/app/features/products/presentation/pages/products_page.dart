import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produtos'),
        centerTitle: true,
      ),
      floatingActionButton: AppFloatingActionButton(
        tooltip: 'Adicionar novo produto',
        icon: Symbols.add_rounded,
        onPressed: () {},
      ),
    );
  }
}
