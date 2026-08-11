import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/core/di/service_locator.dart';
import 'package:estoque_pro/app/core/router/app_routes.dart';
import 'package:estoque_pro/app/features/products/presentation/viewmodels/products_viewmodel.dart';
import 'package:estoque_pro/app/features/products/presentation/widgets/products_list_sliver.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProductsPage extends StatefulWidget {
  final String? initialSearchQuery;

  const ProductsPage({
    super.key,
    this.initialSearchQuery,
  });

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final _viewModel = getIt<ProductsViewModel>();

  @override
  void initState() {
    super.initState();
    _viewModel.listenAll();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialSearchQuery != null) {
        _viewModel.clearLowStockFilter();
        _viewModel.setSearchQuery(widget.initialSearchQuery ?? '');
      }
    });
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
        listenable: _viewModel,
        builder: (context, _) {
          return CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              if (_viewModel.products.isNotEmpty) ...[
                AppFloatingSearch(
                  hint: 'Pesquisar produto...',
                  initialValue: _viewModel.searchQuery,
                  onChanged: _viewModel.setSearchQuery,
                ),
                if (_viewModel.showOnlyLowStock)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: AppSpacing.space16,
                        right: AppSpacing.space16,
                        bottom: AppSpacing.space12,
                      ),
                      child: AppInfoBanner(
                        title: _viewModel.lowStockProducts.length == 1
                            ? '1 produto com estoque baixo'
                            : '${_viewModel.lowStockProducts.length} produtos com estoque baixo',
                        subtitle: 'Exibindo apenas produtos em baixa no estoque',
                        icon: AppIcons.package2,
                        type: AppInfoBannerType.error,
                        trailing: IconButton(
                          icon: const Icon(AppIcons.close),
                          tooltip: 'Exibir todos os produtos',
                          onPressed: _viewModel.clearLowStockFilter,
                        ),
                      ),
                    ),
                  ),
              ],
              ProductsListSliver(viewModel: _viewModel),
            ],
          );
        },
      ),
    );
  }
}
