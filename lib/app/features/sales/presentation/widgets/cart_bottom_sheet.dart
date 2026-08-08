import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_entity.dart';
import 'package:estoque_pro/app/features/sales/presentation/viewmodels/cart_viewmodel.dart';
import 'package:estoque_pro/app/features/sales/presentation/widgets/cart_item_tile.dart';
import 'package:estoque_pro/app/features/sales/presentation/widgets/cart_summary_widget.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

class CartBottomSheet extends StatefulWidget {
  final CartViewModel cartViewModel;
  final List<ProductEntity> availableProducts;
  final VoidCallback onSaleSuccess;

  const CartBottomSheet({
    super.key,
    required this.cartViewModel,
    required this.availableProducts,
    required this.onSaleSuccess,
  });

  @override
  State<CartBottomSheet> createState() => _CartBottomSheetState();
}

class _CartBottomSheetState extends State<CartBottomSheet> {
  final DraggableScrollableController _sheetController = DraggableScrollableController();
  final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  double _getExpandedChildSize(BuildContext context, int itemCount) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    if (screenHeight <= 0) return 0.75;

    final bottomInset = mediaQuery.padding.bottom;
    const headerHeight = 80.0;
    const itemHeight = 76.0;
    const summaryAndPadding = 110.0;

    final totalHeight = headerHeight + (itemCount * itemHeight) + summaryAndPadding + bottomInset;
    final targetSize = totalHeight / screenHeight;

    return targetSize.clamp(0.20, 0.85);
  }

  void _toggleExpand(double expandedSize) {
    if (!_sheetController.isAttached) return;
    final currentSize = _sheetController.size;
    final isExpanded = currentSize > (0.12 + expandedSize) / 2;
    final target = isExpanded ? 0.12 : expandedSize;
    _sheetController.animateTo(
      target,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.cartViewModel,
      builder: (context, _) {
        final vm = widget.cartViewModel;

        if (vm.items.isEmpty) {
          return const SizedBox.shrink();
        }

        final expandedSize = _getExpandedChildSize(context, vm.items.length);

        return DraggableScrollableSheet(
          controller: _sheetController,
          initialChildSize: 0.12,
          minChildSize: 0.12,
          maxChildSize: expandedSize,
          snap: true,
          snapSizes: [0.12, expandedSize],
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: context.colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppSpacing.radius24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
                children: [
                  // Drag Handle & Collapsed Bar Header
                  AnimatedBuilder(
                    animation: _sheetController,
                    builder: (context, _) {
                      final isExpanded = _sheetController.isAttached
                          ? _sheetController.size > (0.12 + expandedSize) / 2
                          : false;

                      return GestureDetector(
                        onTap: () => _toggleExpand(expandedSize),
                        behavior: HitTestBehavior.opaque,
                        child: Column(
                          children: [
                            const Gap(AppSpacing.space8),
                            Center(
                              child: Container(
                                width: 40,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: context.colorScheme.outlineVariant,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                            const Gap(AppSpacing.space8),
                            if (!isExpanded) ...[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Badge(
                                        isLabelVisible: vm.totalItems > 0,
                                        backgroundColor: AppColors.warning,
                                        label: Text(
                                          '${vm.totalItems}',
                                          style: context.textTheme.titleSmall?.copyWith(
                                            color: context.colorScheme.onPrimary,
                                          ),
                                        ),
                                        child: AppButton(
                                          onPressed: () {},
                                          borderRadius: AppSpacing.borderRadius16,
                                          backgroundColor: context.colorScheme.primaryContainer,
                                          child: const Icon(
                                            Symbols.shopping_cart_rounded,
                                            color: AppColors.white,
                                            size: AppSpacing.icon28,
                                            weight: 600,
                                          ),
                                        ),
                                      ),
                                      const Gap(AppSpacing.space16),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Venda ${vm.saleNumber}',
                                            style: context.textTheme.titleSmall?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            '${vm.totalItems} ${vm.totalItems == 1 ? 'item' : 'itens'}',
                                            style: context.textTheme.bodySmall,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Text(
                                    currencyFormat.format(vm.total),
                                    style: context.textTheme.headlineMedium?.copyWith(
                                      color: context.colorScheme.primary,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Icon(
                                    isExpanded ? Icons.keyboard_arrow_down_rounded : Icons.keyboard_arrow_up_rounded,
                                    color: context.colorScheme.primary,
                                  ),
                                ],
                              ),
                            ] else ...[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Carrinho',
                                        style: context.textTheme.titleLarge,
                                      ),
                                      Text(
                                        'Venda ${vm.saleNumber} • ${vm.totalItems} ${vm.totalItems == 1 ? 'item' : 'itens'}',
                                        style: context.textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                  Icon(
                                    isExpanded ? Icons.keyboard_arrow_down_rounded : Icons.keyboard_arrow_up_rounded,
                                    color: context.colorScheme.primary,
                                  ),
                                ],
                              ),
                            ],
                            const Gap(AppSpacing.space8),
                          ],
                        ),
                      );
                    },
                  ),

                  // Expanded Section
                  AnimatedBuilder(
                    animation: _sheetController,
                    builder: (context, _) {
                      final isExpanded = _sheetController.isAttached
                          ? _sheetController.size > (0.12 + expandedSize) / 2
                          : false;

                      if (!isExpanded) return const SizedBox.shrink();

                      return Column(
                        children: [
                          const Divider(),
                          const Gap(AppSpacing.space8),

                          // Cart Items List
                          ...vm.items.map((cartItem) {
                            return CartItemTile(
                              item: cartItem,
                              onIncrease: () => vm.increaseQty(cartItem.product.id),
                              onDecrease: () => vm.decreaseQty(cartItem.product.id),
                              onRemove: () => vm.removeProduct(cartItem.product.id),
                            );
                          }),
                          const Gap(AppSpacing.space12),

                          // Summary
                          CartSummaryWidget(
                            total: vm.total,
                          ),

                          const Gap(AppSpacing.space24),
                        ],
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
