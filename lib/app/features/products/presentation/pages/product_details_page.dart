import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/core/di/service_locator.dart';
import 'package:estoque_pro/app/core/router/app_routes.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_entity.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_history_entity.dart';
import 'package:estoque_pro/app/features/products/presentation/viewmodels/products_form_viewmodel.dart';
import 'package:estoque_pro/app/features/products/presentation/viewmodels/products_viewmodel.dart';
import 'package:estoque_pro/app/features/products/presentation/widgets/product_header_card.dart';
import 'package:estoque_pro/app/features/products/presentation/widgets/product_history_card.dart';
import 'package:estoque_pro/app/features/products/presentation/widgets/product_info_card.dart';
import 'package:estoque_pro/app/features/products/presentation/widgets/product_status_card.dart';
import 'package:estoque_pro/app/features/products/presentation/widgets/product_stock_status_card.dart';
import 'package:estoque_pro/app/features/products/presentation/widgets/stock_adjustment_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

class ProductDetailsPage extends StatefulWidget {
  final ProductEntity product;

  const ProductDetailsPage({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  late final ProductsViewModel _viewModel;
  late final ProductsFormViewModel _formViewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<ProductsViewModel>();
    _formViewModel = getIt<ProductsFormViewModel>();
  }

  ProductEntity get _currentProduct {
    return _viewModel.products.firstWhere(
      (p) => p.id == widget.product.id,
      orElse: () => widget.product,
    );
  }

  Future<void> _adjustStock(ProductHistoryAction action, int quantity, String note) async {
    final product = _currentProduct;

    int newStock = product.stock;
    if (action == ProductHistoryAction.add) {
      newStock += quantity;
    } else {
      newStock = (newStock - quantity).clamp(0, 999999);
    }

    final currentUser = getIt<AuthViewModel>().currentUser;

    final newHistory = [
      ProductHistoryEntity(
        action: action,
        quantity: quantity,
        oldStock: product.stock,
        newStock: newStock,
        date: DateTime.now(),
        note: note,
        userName: currentUser?.name,
        isNew: true,
      ),
      ...product.history,
    ];

    final updatedProduct = product.copyWith(
      stock: newStock,
      isActive: newStock == 0 ? false : product.isActive,
      history: newHistory,
      updatedAt: DateTime.now(),
    );

    await _formViewModel.updateProductCommand.execute(updatedProduct);
  }

  Future<void> _adjustStatus(bool isActive) async {
    final product = _currentProduct;
    if (product.stock == 0 && isActive) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não é possível ativar um produto sem estoque.')),
      );
      return;
    }

    final updatedProduct = product.copyWith(
      isActive: isActive,
      updatedAt: DateTime.now(),
    );

    await _formViewModel.updateProductCommand.execute(updatedProduct);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final product = _currentProduct;

        final maxProgress = product.minStock > 0 ? (product.minStock * 2).toDouble() : 10.0;
        final rawProgress = maxProgress > 0 ? product.stock / maxProgress : 0.0;

        final Color statusColor;
        final IconData statusIcon;
        final String statusText;

        if (rawProgress <= 0.0) {
          statusColor = AppColors.error;
          statusIcon = Symbols.error_rounded;
          statusText = 'Sem Estoque';
        } else if (rawProgress < 0.25) {
          statusColor = AppColors.error;
          statusIcon = Symbols.info_rounded;
          statusText = 'Estoque Crítico';
        } else if (rawProgress < 0.50) {
          statusColor = AppColors.warning;
          statusIcon = Symbols.info_rounded;
          statusText = 'Estoque Baixo';
        } else {
          statusColor = AppColors.success;
          statusIcon = Symbols.check_circle_rounded;
          statusText = 'Estoque OK';
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Detalhes do Produto'),
            actions: [
              AppIconButton(
                icon: Symbols.edit_rounded,
                onPressed: () => context.push(AppRoutes.productForm, extra: product),
              ),
              const Gap(AppSpacing.space8),
            ],
          ),
          body: ListView(
            padding: const .all(AppSpacing.space16),
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
                onAdjustPressed: () => StockAdjustmentBottomSheet.show(context, product, _adjustStock),
              ),
              const Gap(AppSpacing.space16),

              ProductInfoCard(
                product: product,
                rawProgress: rawProgress,
                statusColor: statusColor,
              ),
              const Gap(AppSpacing.space16),

              ProductHistoryCard(product: product),

              const Gap(AppSpacing.space56),
            ],
          ),
        );
      },
    );
  }
}
