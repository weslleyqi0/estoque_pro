import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/core/router/app_routes.dart';
import 'package:estoque_pro/app/core/utils/currency_input_formatter.dart';
import 'package:estoque_pro/app/features/products/presentation/viewmodels/archived_products_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class ArchivedProductsPage extends StatefulWidget {
  final ArchivedProductsViewModel Function() viewModelFactory;

  const ArchivedProductsPage({
    super.key,
    required this.viewModelFactory,
  });

  @override
  State<ArchivedProductsPage> createState() => _ArchivedProductsPageState();
}

class _ArchivedProductsPageState extends State<ArchivedProductsPage> {
  late final ArchivedProductsViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = widget.viewModelFactory();
    viewModel.listenAll();
  }

  @override
  void dispose() {
    viewModel.setSearchQuery('', notify: false);
    super.dispose();
  }

  Future<void> _unarchive(String id, String name) async {
    try {
      await viewModel.unarchiveProduct(id);
      if (mounted) {
        AppSnackbar.success(context, 'Produto "$name" restaurado para a lista (desativado).');
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.error(context, 'Erro ao restaurar produto: $e');
      }
    }
  }

  Future<void> _deletePermanently(String id, String name) async {
    final confirmed = await AppDialog.showConfirmation(
      context: context,
      title: 'Excluir Permanentemente',
      content:
          'Atenção! Ao excluir permanentemente o produto "$name", TODO O SEU HISTÓRICO DE MOVIMENTAÇÕES DE ESTOQUE SERÁ EXCLUÍDO e os registros vinculados não poderão ser recuperados.\n\nDeseja continuar?',
      confirmLabel: 'Sim, Excluir Permanentemente',
      cancelLabel: 'Cancelar',
      isDestructive: true,
    );

    if (confirmed == true && mounted) {
      try {
        await viewModel.deletePermanently(id);
        if (mounted) {
          AppSnackbar.success(context, 'Produto e histórico de movimentações excluídos permanentemente.');
        }
      } catch (e) {
        if (mounted) {
          AppSnackbar.error(context, 'Erro ao excluir permanentemente: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produtos Arquivados'),
        centerTitle: true,
      ),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          final archivedList = viewModel.filteredArchivedProducts;

          return CustomScrollView(
            slivers: [
              if (viewModel.archivedProducts.isNotEmpty)
                AppFloatingSearch(
                  hint: 'Pesquisar produto arquivado...',
                  initialValue: viewModel.searchQuery,
                  onChanged: viewModel.setSearchQuery,
                ),
              if (viewModel.state == ArchivedProductsLoadState.loading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (viewModel.archivedProducts.isEmpty)
                const SliverFillRemaining(
                  child: AppEmptyList(
                    message: 'Nenhum produto arquivado.',
                    icon: AppIcons.inventory2,
                  ),
                )
              else if (archivedList.isEmpty)
                SliverFillRemaining(
                  child: AppEmptyList(
                    message: 'Nenhum produto arquivado encontrado para "${viewModel.searchQuery}".',
                    icon: AppIcons.searchOff,
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.all(AppSpacing.space16),
                  sliver: SliverList.builder(
                    itemCount: archivedList.length,
                    itemBuilder: (context, index) {
                      final product = archivedList[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: AppSpacing.space12),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppSpacing.borderRadius16,
                          side: BorderSide(
                            color: context.colorScheme.outlineVariant.withValues(alpha: 0.5),
                          ),
                        ),
                        child: InkWell(
                          onTap: () => context.push(AppRoutes.productDetails, extra: product),
                          borderRadius: AppSpacing.borderRadius16,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: AppSpacing.space12,
                              top: AppSpacing.space8,
                              bottom: AppSpacing.space12,
                              right: AppSpacing.space4,
                            ),
                            child: Row(
                              children: [
                                AppNetworkImage(
                                  imageUrl: product.imgUrl,
                                  isGrayscale: true,
                                ),
                                const Gap(AppSpacing.space12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: context.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: context.colorScheme.onSurface.withValues(alpha: 0.4),
                                        ),
                                      ),
                                      const Gap(2),
                                      Text(
                                        CurrencyInputFormatter.formatCurrency(product.price),
                                        style: context.textTheme.bodyMedium?.copyWith(
                                          color: context.colorScheme.onSurface.withValues(alpha: 0.4),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Gap(2),
                                      Text(
                                        'Estoque: ${product.stock} un.',
                                        style: context.textTheme.bodySmall?.copyWith(
                                          color: context.colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    AppIconButton(
                                      size: AppIconButtonSize.large,
                                      icon: Icons.unarchive_outlined,
                                      visualDensity: VisualDensity.compact,
                                      iconColor: context.colorScheme.primary,
                                      tooltip: 'Restaurar produto',
                                      onPressed: () => _unarchive(product.id, product.name),
                                    ),
                                    AppIconButton(
                                      size: AppIconButtonSize.large,
                                      icon: Icons.delete_forever_outlined,
                                      visualDensity: VisualDensity.compact,
                                      iconColor: context.colorScheme.error,
                                      tooltip: 'Excluir permanentemente',
                                      onPressed: () => _deletePermanently(product.id, product.name),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
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
