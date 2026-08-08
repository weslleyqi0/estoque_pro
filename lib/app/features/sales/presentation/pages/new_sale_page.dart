import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/core/di/service_locator.dart';
import 'package:estoque_pro/app/features/products/presentation/viewmodels/products_viewmodel.dart';
import 'package:estoque_pro/app/features/sales/presentation/widgets/sale_products_list_sliver.dart';
import 'package:flutter/material.dart';

class NewSalePage extends StatefulWidget {
  const NewSalePage({super.key});

  @override
  State<NewSalePage> createState() => _NewSalePageState();
}

class _NewSalePageState extends State<NewSalePage> {
  final _productsVM = getIt<ProductsViewModel>();

  @override
  void initState() {
    super.initState();
    _productsVM.listenAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Venda'),
        centerTitle: true,
      ),
      body: ListenableBuilder(
        listenable: _productsVM,
        builder: (context, _) {
          return CustomScrollView(
            slivers: [
              // Top Search
              AppFloatingSearch(
                hint: 'Buscar por nome, categoria, fornecedor ou código...',
                onChanged: _productsVM.setSearchQuery,
              ),

              // Products List
              SaleProductsListSliver(viewModel: _productsVM),
            ],
          );
        },
      ),
    );
  }
}
