import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/features/products/presentation/viewmodels/products_viewmodel.dart';
import 'package:estoque_pro/app/features/products/presentation/widgets/products_item.dart';
import 'package:flutter/material.dart';

class ProductsListSliver extends StatelessWidget {
  final ProductsViewModel viewModel;

  const ProductsListSliver({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    if (viewModel.isLoading) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (viewModel.isFailure) {
      return SliverFillRemaining(
        child: Center(child: Text(viewModel.error.toString())),
      );
    }

    if (viewModel.products.isEmpty) {
      return const SliverFillRemaining(
        child: AppEmptyList(
          message: 'Nenhum produto cadastrado!\nClique no botão abaixo para cadastrar um novo produto.',
          icon: AppIcons.inventory2,
          iconColor: Colors.cyan,
          iconSize: AppSpacing.icon48,
        ),
      );
    }

    if (viewModel.filteredProducts.isEmpty) {
      final isLowStock = viewModel.showOnlyLowStock;
      final isEmptyStock = viewModel.showOnlyEmptyStock;
      final isInactive = viewModel.showOnlyInactive;
      final hasSearchQuery = viewModel.searchQuery.trim().isNotEmpty;

      final emptyMessage = isInactive && !hasSearchQuery
          ? 'Nenhum produto desativado!'
          : isEmptyStock && !hasSearchQuery
              ? 'Nenhum produto com estoque vazio!'
              : isLowStock && !hasSearchQuery
                  ? 'Nenhum produto com estoque baixo!'
                  : 'Nenhum produto encontrado para essa pesquisa.';

      return SliverFillRemaining(
        child: AppEmptyList(
          message: emptyMessage,
          icon: (isLowStock || isEmptyStock || isInactive) && !hasSearchQuery ? AppIcons.package2 : AppIcons.searchOff,
          iconColor: Colors.grey,
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
            final product = viewModel.filteredProducts[index];
            return ProductsItem(product: product);
          },
          childCount: viewModel.filteredProducts.length,
        ),
      ),
    );
  }
}
