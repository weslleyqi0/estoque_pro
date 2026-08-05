import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/core/di/service_locator.dart';
import 'package:estoque_pro/app/core/router/app_routes.dart';
import 'package:estoque_pro/app/features/products/presentation/viewmodels/products_viewmodel.dart';
import 'package:estoque_pro/app/features/products/presentation/widgets/products_list_sliver.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final _viewModel = getIt<ProductsViewModel>();

  @override
  void initState() {
    super.initState();

    _viewModel.listenAll();
  }

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
        onPressed: () => context.push(AppRoutes.productForm),
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          return CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              ProductsListSliver(viewModel: _viewModel),
            ],
          );
        },
      ),
    );
  }
}
