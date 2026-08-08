import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/core/di/service_locator.dart';
import 'package:estoque_pro/app/features/products/presentation/viewmodels/products_viewmodel.dart';
import 'package:estoque_pro/app/features/sales/presentation/viewmodels/cart_viewmodel.dart';
import 'package:estoque_pro/app/features/sales/presentation/widgets/sale_products_list_sliver.dart';
import 'package:flutter/material.dart';

class NewSalePage extends StatefulWidget {
  const NewSalePage({super.key});

  @override
  State<NewSalePage> createState() => _NewSalePageState();
}

class _NewSalePageState extends State<NewSalePage> {
  final _productsVM = getIt<ProductsViewModel>();
  final _cartVM = getIt<CartViewModel>();

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
        listenable: Listenable.merge([_productsVM, _cartVM]),
        builder: (context, _) {
          return CustomScrollView(
            slivers: [
              // Top Search
              AppFloatingSearch(
                hint: 'Buscar por nome, categoria, fornecedor ou código...',
                onChanged: _productsVM.setSearchQuery,
              ),

              // Products List
              SaleProductsListSliver(viewModel: _productsVM, cartVM: _cartVM),
            ],
          );
        },
      ),
    );
  }
}
