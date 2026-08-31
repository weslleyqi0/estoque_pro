import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/core/router/app_routes.dart';
import 'package:estoque_pro/app/features/products/presentation/viewmodels/products_viewmodel.dart';
import 'package:estoque_pro/app/features/sales/presentation/widgets/product_sale_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SelectProductPage extends StatefulWidget {
  final ProductsViewModel viewModel;
  final String? title;

  const SelectProductPage({
    super.key,
    required this.viewModel,
    this.title,
  });

  @override
  State<SelectProductPage> createState() => _SelectProductPageState();
}

class _SelectProductPageState extends State<SelectProductPage> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.listenAll();
  }

  @override
  void dispose() {
    widget.viewModel.setSearchQuery('', notify: false);
    widget.viewModel.clearLowStockFilter(notify: false);
    super.dispose();
  }

  Future<void> _openBarcodeScanner() async {
    final scannedCode = await context.push<String>(AppRoutes.saleScanner);
    if (scannedCode != null && mounted) {
      widget.viewModel.setSearchQuery(scannedCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'Selecionar Produto'),
        centerTitle: true,
      ),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          final products = widget.viewModel.filteredProducts.where((p) => p.isActive).toList();

          return CustomScrollView(
            slivers: [
              AppFloatingSearch(
                hint: 'Buscar por nome, categoria, fornecedor ou código...',
                initialValue: widget.viewModel.searchQuery,
                onChanged: widget.viewModel.setSearchQuery,
                trailing: Tooltip(
                  message: 'Abrir leitor de código de barras',
                  child: InkWell(
                    onTap: _openBarcodeScanner,
                    child: Container(
                      height: 68,
                      width: 68,
                      decoration: BoxDecoration(
                        color: context.colorScheme.primary,
                        borderRadius: BorderRadius.circular(AppSpacing.radius16),
                        border: Border.all(color: context.colorScheme.primary, width: 1.0),
                      ),
                      child: Icon(
                        AppIcons.barcodeScanner,
                        color: context.colorScheme.surface,
                        size: AppSpacing.icon32,
                      ),
                    ),
                  ),
                ),
              ),
              if (widget.viewModel.isLoading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (products.isEmpty)
                SliverFillRemaining(
                  child: AppEmptyList(
                    message: widget.viewModel.searchQuery.isNotEmpty
                        ? 'Nenhum produto encontrado para "${widget.viewModel.searchQuery}"'
                        : 'Nenhum produto disponível.',
                    icon: widget.viewModel.searchQuery.isNotEmpty ? AppIcons.searchOff : AppIcons.inventory2,
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
                  sliver: SliverList.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ProductSaleCard(
                        product: product,
                        cartQuantity: 0,
                        onAdd: () => Navigator.pop(context, product),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
