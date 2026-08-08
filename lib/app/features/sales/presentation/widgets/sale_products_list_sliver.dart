import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/features/products/presentation/viewmodels/products_viewmodel.dart';
import 'package:estoque_pro/app/features/sales/presentation/widgets/product_sale_card.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class SaleProductsListSliver extends StatelessWidget {
  final ProductsViewModel viewModel;

  const SaleProductsListSliver({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    final products = viewModel.filteredProducts.where((p) => p.isActive).toList();

    if (viewModel.state == ProductsLoadState.loading) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (viewModel.state == ProductsLoadState.failure) {
      return SliverFillRemaining(
        child: Center(child: Text(viewModel.error.toString())),
      );
    }

    if (products.isEmpty) {
      return SliverFillRemaining(
        child: AppEmptyList(
          message: viewModel.searchQuery.isNotEmpty
              ? 'Nenhum produto encontrado para "${viewModel.searchQuery}"'
              : 'Nenhum produto disponível para venda.',
          icon: viewModel.searchQuery.isNotEmpty
              ? Symbols.search_off_rounded
              : Symbols.inventory_2_rounded,
          iconColor: viewModel.searchQuery.isNotEmpty ? Colors.grey : Colors.cyan,
          iconSize: AppSpacing.icon48,
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.only(
        left: AppSpacing.space16,
        right: AppSpacing.space16,
        bottom: AppSpacing.space32,
      ),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final product = products[index];
            return ProductSaleCard(
              product: product,
              cartQuantity: 0,
              onAdd: () {},
            );
          },
          childCount: products.length,
        ),
      ),
    );
  }
}
