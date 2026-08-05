import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/features/products/presentation/viewmodels/products_viewmodel.dart';
import 'package:estoque_pro/app/features/products/presentation/widgets/products_item.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class ProductsListSliver extends StatelessWidget {
  final ProductsViewModel viewModel;

  const ProductsListSliver({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
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

    if (viewModel.products.isEmpty) {
      return const SliverFillRemaining(
        child: AppEmptyList(
          message: 'Nenhum produto cadastrado!\nClique no botão abaixo para cadastrar um novo produto.',
          icon: Symbols.inventory_2_rounded,
          iconColor: Colors.cyan,
          iconSize: AppSpacing.icon48,
        ),
      );
    }

    if (viewModel.filteredProducts.isEmpty) {
      return const SliverFillRemaining(
        child: AppEmptyList(
          message: 'Nenhum produto encontrado para essa pesquisa.',
          icon: Symbols.search_off_rounded,
          iconColor: Colors.grey,
          iconSize: AppSpacing.icon48,
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.only(
        left: AppSpacing.space8,
        right: AppSpacing.space8,
        bottom: AppSpacing.space32,
      ),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final product = viewModel.filteredProducts[index];
            return ProductsItem(product: product);
          },
          childCount: viewModel.filteredProducts.length,
        ),
      ),
    );
  }
}
