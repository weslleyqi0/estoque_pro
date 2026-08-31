import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/core/router/app_routes.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_entity.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_history_entity.dart';
import 'package:estoque_pro/app/features/products/presentation/extensions/product_stock_ui_extension.dart';
import 'package:estoque_pro/app/features/products/presentation/viewmodels/products_form_viewmodel.dart';
import 'package:estoque_pro/app/features/products/presentation/viewmodels/products_viewmodel.dart';
import 'package:estoque_pro/app/features/products/presentation/widgets/product_financial_card.dart';
import 'package:estoque_pro/app/features/products/presentation/widgets/product_header_card.dart';
import 'package:estoque_pro/app/features/products/presentation/widgets/product_history_card.dart';
import 'package:estoque_pro/app/features/products/presentation/widgets/product_info_card.dart';
import 'package:estoque_pro/app/features/products/presentation/widgets/product_status_card.dart';
import 'package:estoque_pro/app/features/products/presentation/widgets/product_stock_status_card.dart';
import 'package:estoque_pro/app/features/products/presentation/widgets/stock_adjustment_bottom_sheet.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_permission.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_role.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class ProductDetailsPage extends StatefulWidget {
  final ProductEntity product;
  final ProductsViewModel viewModel;
  final ProductsFormViewModel formViewModel;
  final AuthViewModel authViewModel;

  const ProductDetailsPage({
    super.key,
    required this.product,
    required this.viewModel,
    required this.formViewModel,
    required this.authViewModel,
  });

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  ProductsViewModel get _viewModel => widget.viewModel;
  ProductsFormViewModel get _formViewModel => widget.formViewModel;
  AuthViewModel get _authViewModel => widget.authViewModel;

  @override
  void initState() {
    super.initState();
    _viewModel.listenAll();
    _viewModel.listenProductHistory(widget.product.id, limit: 6);
  }

  @override
  void didUpdateWidget(covariant ProductDetailsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.product.id != widget.product.id) {
      _viewModel.listenProductHistory(widget.product.id, limit: 6);
    }
  }

  ProductEntity get _currentProduct {
    return _viewModel.products.firstWhere(
      (p) => p.id == widget.product.id,
      orElse: () => widget.product,
    );
  }

  Future<void> _adjustStock(ProductHistoryAction action, int quantity, String note) async {
    final product = _currentProduct;
    final currentUser = _authViewModel.currentUser;

    int quantityDiff = action == ProductHistoryAction.add ? quantity : -quantity;
    int oldStock = product.stock;
    int newStock = oldStock + quantityDiff;

    final history = ProductHistoryEntity(
      action: action,
      quantity: quantity,
      oldStock: oldStock,
      newStock: newStock,
      date: DateTime.now(),
      note: note,
      userName: currentUser?.name,
      isNew: true,
    );

    await _formViewModel.adjustStockCommand.execute((
      productId: product.id,
      quantityDiff: quantityDiff,
      history: history,
    ));
  }

  Future<void> _adjustStatus(bool isActive) async {
    final product = _currentProduct;
    if (product.isArchived && isActive) {
      AppSnackbar.warning(context, 'Não é possível ativar um produto arquivado. Restaure-o primeiro.');
      return;
    }

    if (product.stock == 0 && isActive) {
      AppSnackbar.warning(context, 'Não é possível ativar um produto sem estoque.');
      return;
    }

    final updatedProduct = product.copyWith(
      isActive: isActive,
      isArchived: product.isArchived,
      updatedAt: DateTime.now(),
    );

    await _formViewModel.updateProductCommand.execute(updatedProduct);
  }

  Future<void> _archive() async {
    final product = _currentProduct;
    final confirm = await AppDialog.showConfirmation(
      context: context,
      title: 'Arquivar Produto',
      content: 'Deseja arquivar este produto? Ele deixará de ser exibido na lista principal e nas vendas.',
      confirmLabel: 'Arquivar',
      isDestructive: true,
    );

    if (confirm == true && mounted) {
      try {
        await _viewModel.archiveProduct(product.id);
        if (mounted) {
          AppSnackbar.success(context, 'Produto arquivado com sucesso!');
        }
      } catch (e) {
        if (mounted) {
          AppSnackbar.error(context, 'Erro ao arquivar produto: $e');
        }
      }
    }
  }

  Future<void> _unarchive() async {
    final product = _currentProduct;
    final confirm = await AppDialog.showConfirmation(
      context: context,
      title: 'Restaurar Produto',
      content: 'Deseja restaurar este produto? Ele retornará para a lista de produtos como desativado.',
      confirmLabel: 'Restaurar',
    );

    if (confirm == true && mounted) {
      try {
        await _viewModel.unarchiveProduct(product.id);
        if (mounted) {
          AppSnackbar.success(context, 'Produto restaurado! Ele permanece desativado até ser ativado.');
        }
      } catch (e) {
        if (mounted) {
          AppSnackbar.error(context, 'Erro ao restaurar produto: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([_viewModel, _formViewModel, _authViewModel]),
      builder: (context, _) {
        final product = _currentProduct;
        final rawProgress = product.rawStockProgress;
        final currentUser = _authViewModel.currentUser;
        final canViewHistory = currentUser?.hasPermission(UserPermission.viewHistory) ?? false;
        final canEditProducts = currentUser?.hasPermission(UserPermission.editProducts) ?? false;
        final canManageStock = currentUser?.hasPermission(UserPermission.manageStock) ?? false;
        final canViewFinancialCard = currentUser?.role == UserRole.admin || currentUser?.role == UserRole.owner;

        final Color statusColor;
        final IconData statusIcon;
        final String statusText;

        if (rawProgress <= 0.0) {
          statusColor = AppColors.error;
          statusIcon = AppIcons.error;
          statusText = 'Sem Estoque';
        } else if (rawProgress < 0.25) {
          statusColor = AppColors.error;
          statusIcon = AppIcons.info;
          statusText = 'Estoque Crítico';
        } else if (rawProgress < 0.50) {
          statusColor = AppColors.warning;
          statusIcon = AppIcons.info;
          statusText = 'Estoque Baixo';
        } else {
          statusColor = AppColors.success;
          statusIcon = AppIcons.checkCircle;
          statusText = 'Estoque OK';
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Detalhes do Produto'),
            actions: [
              if (canEditProducts)
                AppIconButton(
                  icon: AppIcons.edit,
                  tooltip: 'Editar produto',
                  onPressed: () => context.push(AppRoutes.productForm, extra: product),
                ),
              AppIconButton(
                icon: product.isArchived ? Icons.unarchive_outlined : AppIcons.inventory2,
                tooltip: product.isArchived ? 'Restaurar produto' : 'Arquivar produto',
                onPressed: () => product.isArchived ? _unarchive() : _archive(),
              ),
              const Gap(AppSpacing.space8),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(AppSpacing.space16),
            children: [
              ProductHeaderCard(product: product),

              ProductStatusCard(
                product: product,
                onStatusChanged: _adjustStatus,
              ),
              const Gap(AppSpacing.space16),

              ProductStockStatusCard(
                product: product,
                statusText: statusText,
                statusColor: statusColor,
                statusIcon: statusIcon,
                onAdjustPressed: canManageStock
                    ? () => StockAdjustmentBottomSheet.show(context, product, _adjustStock)
                    : null,
              ),
              const Gap(AppSpacing.space16),
              ProductInfoCard(
                product: product,
                rawProgress: rawProgress,
                statusColor: statusColor,
              ),

              const Gap(AppSpacing.space16),
              if (canViewFinancialCard) ...[
                ProductFinancialCard(product: product),
                const Gap(AppSpacing.space16),
              ],

              if (canViewHistory) ...[
                ProductHistoryCard(
                  title: 'Histórico de Movimentações',
                  subtitle: 'Últimas movimentações',
                  history: _viewModel.productHistory.length > 5
                      ? _viewModel.productHistory.take(5).toList()
                      : _viewModel.productHistory,
                  showEmptyMessage: true,
                  onViewAll: _viewModel.productHistory.length > 5
                      ? () => context.push(AppRoutes.productHistory, extra: product)
                      : null,
                ),
                const Gap(AppSpacing.space16),
              ],

              const Gap(AppSpacing.space56),
            ],
          ),
        );
      },
    );
  }
}
