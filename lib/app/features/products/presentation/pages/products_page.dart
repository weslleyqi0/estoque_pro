import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/core/router/app_routes.dart';
import 'package:estoque_pro/app/features/products/presentation/viewmodels/products_viewmodel.dart';
import 'package:estoque_pro/app/features/products/presentation/widgets/products_list_sliver.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProductsPage extends StatefulWidget {
  final ProductsViewModel viewModel;
  final String? initialSearchQuery;

  const ProductsPage({
    super.key,
    required this.viewModel,
    this.initialSearchQuery,
  });

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.listenAll();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialSearchQuery != null) {
        widget.viewModel.clearLowStockFilter();
        widget.viewModel.setSearchQuery(widget.initialSearchQuery ?? '');
      }
    });
  }

  @override
  void dispose() {
    widget.viewModel.setSearchQuery('', notify: false);
    widget.viewModel.clearLowStockFilter(notify: false);
    super.dispose();
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
        icon: AppIcons.add,
        onPressed: () => context.push(AppRoutes.productForm),
      ),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          return CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              if (widget.viewModel.products.isNotEmpty) ...[
                AppFloatingSearch(
                  hint: 'Pesquisar produto...',
                  initialValue: widget.viewModel.searchQuery,
                  onChanged: widget.viewModel.setSearchQuery,
                ),
                if (widget.viewModel.showOnlyLowStock)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: AppSpacing.space16,
                        right: AppSpacing.space16,
                        bottom: AppSpacing.space12,
                      ),
                      child: AppInfoBanner(
                        title: widget.viewModel.lowStockProducts.length == 1
                            ? '1 produto com estoque baixo'
                            : '${widget.viewModel.lowStockProducts.length} produtos com estoque baixo',
                        subtitle: 'Exibindo apenas produtos em baixa no estoque',
                        icon: AppIcons.package2,
                        type: AppInfoBannerType.error,
                        trailing: IconButton(
                          icon: const Icon(AppIcons.close),
                          tooltip: 'Exibir todos os produtos',
                          onPressed: widget.viewModel.clearLowStockFilter,
                        ),
                      ),
                    ),
                  ),
              ],
              ProductsListSliver(viewModel: widget.viewModel),
            ],
          );
        },
      ),
    );
  }
}
