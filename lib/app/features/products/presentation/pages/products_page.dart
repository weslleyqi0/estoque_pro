import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/core/router/app_routes.dart';
import 'package:estoque_pro/app/features/products/presentation/viewmodels/products_viewmodel.dart';
import 'package:estoque_pro/app/features/products/presentation/widgets/products_list_sliver.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class ProductsPage extends StatefulWidget {
  final ProductsViewModel Function() viewModelFactory;
  final String? initialSearchQuery;
  final bool initialShowOnlyLowStock;
  final bool initialShowOnlyEmptyStock;
  final bool initialShowOnlyInactive;

  const ProductsPage({
    super.key,
    required this.viewModelFactory,
    this.initialSearchQuery,
    this.initialShowOnlyLowStock = false,
    this.initialShowOnlyEmptyStock = false,
    this.initialShowOnlyInactive = false,
  });

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  late final ProductsViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = widget.viewModelFactory();
    if (widget.initialShowOnlyInactive) {
      viewModel.setShowOnlyInactive(true);
    } else if (widget.initialShowOnlyEmptyStock) {
      viewModel.setShowOnlyEmptyStock(true);
    } else if (widget.initialShowOnlyLowStock) {
      viewModel.setShowOnlyLowStock(true);
    }
    viewModel.listenAll();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialSearchQuery != null && widget.initialSearchQuery!.isNotEmpty) {
        viewModel.clearLowStockFilter();
        viewModel.clearEmptyStockFilter();
        viewModel.clearInactiveFilter();
        viewModel.setSearchQuery(widget.initialSearchQuery!);
      }
    });
  }

  @override
  void dispose() {
    viewModel.setSearchQuery('', notify: false);
    viewModel.clearLowStockFilter(notify: false);
    viewModel.clearEmptyStockFilter(notify: false);
    viewModel.clearInactiveFilter(notify: false);
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produtos'),
        centerTitle: true,
        actions: [
          ListenableBuilder(
            listenable: viewModel,
            builder: (context, _) {
              if (viewModel.archivedProducts.isEmpty) {
                return const SizedBox.shrink();
              }
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppIconButton(
                    size: AppIconButtonSize.medium,
                    icon: Icons.inventory_2_outlined,
                    iconColor: context.colorScheme.primary,
                    tooltip: 'Produtos Arquivados',
                    onPressed: () => context.push(AppRoutes.archivedProducts),
                  ),
                  const Gap(AppSpacing.space8),
                ],
              );
            },
          ),
        ],
      ),
      floatingActionButton: AppFloatingActionButton(
        tooltip: 'Adicionar novo produto',
        icon: AppIcons.add,
        onPressed: () => context.push(AppRoutes.productForm),
      ),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          return CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              if (viewModel.products.isNotEmpty) ...[
                AppFloatingSearch(
                  hint: 'Pesquisar produto...',
                  initialValue: viewModel.searchQuery,
                  onChanged: viewModel.setSearchQuery,
                ),
                if (viewModel.showOnlyLowStock)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: AppSpacing.space16,
                        right: AppSpacing.space16,
                        bottom: AppSpacing.space12,
                      ),
                      child: AppInfoBanner(
                        title: viewModel.lowStockProducts.length == 1
                            ? '1 produto com estoque baixo'
                            : '${viewModel.lowStockProducts.length} produtos com estoque baixo',
                        subtitle: 'Exibindo apenas produtos em baixa no estoque',
                        icon: AppIcons.package2,
                        type: AppInfoBannerType.warning,
                        trailing: AppIconButton(
                          icon: AppIcons.close,
                          iconColor: AppColors.warningDark,
                          tooltip: 'Exibir todos os produtos',
                          onPressed: viewModel.clearLowStockFilter,
                        ),
                      ),
                    ),
                  ),
                if (viewModel.showOnlyEmptyStock)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: AppSpacing.space16,
                        right: AppSpacing.space16,
                        bottom: AppSpacing.space12,
                      ),
                      child: AppInfoBanner(
                        title: viewModel.emptyStockProducts.length == 1
                            ? '1 produto com estoque vazio'
                            : '${viewModel.emptyStockProducts.length} produtos com estoque vazio',
                        subtitle: 'Exibindo apenas produtos com estoque zerado',
                        icon: AppIcons.package2,
                        type: AppInfoBannerType.error,
                        trailing: AppIconButton(
                          icon: AppIcons.close,
                          iconColor: AppColors.error,
                          tooltip: 'Exibir todos os produtos',
                          onPressed: viewModel.clearEmptyStockFilter,
                        ),
                      ),
                    ),
                  ),
                if (viewModel.showOnlyInactive)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: AppSpacing.space16,
                        right: AppSpacing.space16,
                        bottom: AppSpacing.space12,
                      ),
                      child: AppInfoBanner(
                        title: viewModel.inactiveProducts.length == 1
                            ? '1 produto desativado'
                            : '${viewModel.inactiveProducts.length} produtos desativados',
                        subtitle: 'Exibindo apenas produtos desativados',
                        icon: AppIcons.package2,
                        type: AppInfoBannerType.warning,
                        trailing: AppIconButton(
                          icon: AppIcons.close,
                          iconColor: AppColors.warningDark,
                          tooltip: 'Exibir todos os produtos',
                          onPressed: viewModel.clearInactiveFilter,
                        ),
                      ),
                    ),
                  ),
              ],
              ProductsListSliver(viewModel: viewModel),
            ],
          );
        },
      ),
    );
  }
}
