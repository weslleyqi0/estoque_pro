import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/core/di/service_locator.dart';
import 'package:estoque_pro/app/features/products/presentation/viewmodels/products_viewmodel.dart';
import 'package:estoque_pro/app/features/sales/presentation/viewmodels/cart_viewmodel.dart';
import 'package:estoque_pro/app/features/sales/presentation/widgets/cart_bottom_sheet.dart';
import 'package:estoque_pro/app/features/sales/presentation/widgets/sale_products_list_sliver.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NewSalePage extends StatefulWidget {
  const NewSalePage({super.key});

  @override
  State<NewSalePage> createState() => _NewSalePageState();
}

class _NewSalePageState extends State<NewSalePage> {
  final _productsViewModel = getIt<ProductsViewModel>();
  final _cartViewModel = getIt<CartViewModel>();

  @override
  void initState() {
    super.initState();
    _productsViewModel.listenAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Venda'),
        centerTitle: true,
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([_productsViewModel, _cartViewModel]),
        builder: (context, _) {
          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  // Top Search
                  AppFloatingSearch(
                    hint: 'Buscar por nome, categoria, fornecedor ou código...',
                    onChanged: _productsViewModel.setSearchQuery,
                  ),

                  // Products List
                  SaleProductsListSliver(
                    productsViewModel: _productsViewModel,
                    cartViewModel: _cartViewModel,
                  ),
                ],
              ),

              // Persistent Cart Bottom Sheet
              CartBottomSheet(
                cartViewModel: _cartViewModel,
                availableProducts: _productsViewModel.products,
                onSaleSuccess: () {
                  AppSnackbar.success(context, 'Venda realizada com sucesso!');
                  context.pop();
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
