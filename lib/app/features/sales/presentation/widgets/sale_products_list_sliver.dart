import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_entity.dart';
import 'package:estoque_pro/app/features/products/presentation/viewmodels/products_viewmodel.dart';
import 'package:estoque_pro/app/features/sales/presentation/viewmodels/cart_viewmodel.dart';
import 'package:estoque_pro/app/features/sales/presentation/widgets/product_sale_card.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class SaleProductsListSliver extends StatelessWidget {
  final ProductsViewModel productsViewModel;
  final CartViewModel cartViewModel;

  const SaleProductsListSliver({
    super.key,
    required this.productsViewModel,
    required this.cartViewModel,
  });

  @override
  Widget build(BuildContext context) {
    final products = productsViewModel.filteredProducts.where((p) => p.isActive).toList();

    if (productsViewModel.state == ProductsLoadState.loading) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (productsViewModel.state == ProductsLoadState.failure) {
      return SliverFillRemaining(
        child: Center(child: Text(productsViewModel.error.toString())),
      );
    }

    if (products.isEmpty) {
      return SliverFillRemaining(
        child: AppEmptyList(
          message: productsViewModel.searchQuery.isNotEmpty
              ? 'Nenhum produto encontrado para "${productsViewModel.searchQuery}"'
              : 'Nenhum produto disponível para venda.',
          icon: productsViewModel.searchQuery.isNotEmpty ? Symbols.search_off_rounded : Symbols.inventory_2_rounded,
          iconColor: productsViewModel.searchQuery.isNotEmpty ? Colors.grey : Colors.cyan,
          iconSize: AppSpacing.icon48,
        ),
      );
    }

    final bottomPadding = cartViewModel.items.isNotEmpty ? 120.0 : AppSpacing.space32;

    return SliverPadding(
      padding: EdgeInsets.only(
        left: AppSpacing.space16,
        right: AppSpacing.space16,
        bottom: bottomPadding,
      ),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final product = products[index];
            final cartQty = cartViewModel.getQuantityInCart(product.id);
            return ProductSaleCard(
              product: product,
              cartQuantity: cartQty,
              onAdd: () => _onAddProduct(context, product),
            );
          },
          childCount: products.length,
        ),
      ),
    );
  }

  void _onAddProduct(BuildContext context, ProductEntity product) {
    final added = cartViewModel.addProduct(product);
    if (!added) {
      final stock = product.stock;
      final unidade = stock == 1 ? 'unidade disponível' : 'unidades disponíveis';
      AppSnackbar.warning(
        context,
        'Estoque insuficiente! Apenas $stock $unidade de "${product.name}".',
      );
    }
  }
}
