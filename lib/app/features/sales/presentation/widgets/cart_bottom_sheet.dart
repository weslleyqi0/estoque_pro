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

  static const double _collapsedSize = 0.12;
  static const double _expandedSize = 1.0;

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    if (!_sheetController.isAttached) return;
    final currentSize = _sheetController.size;
    final isExpanded = currentSize > (_collapsedSize + _expandedSize) / 2;
    final target = isExpanded ? _collapsedSize : _expandedSize;
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

        return DraggableScrollableSheet(
          controller: _sheetController,
          initialChildSize: _collapsedSize,
          minChildSize: _collapsedSize,
          maxChildSize: _expandedSize,
          snap: true,
          snapSizes: const [_collapsedSize, _expandedSize],
          builder: (context, scrollController) {
            return AnimatedBuilder(
              animation: _sheetController,
              builder: (context, _) {
                final isExpanded = _sheetController.isAttached
                    ? _sheetController.size > (_collapsedSize + _expandedSize) / 2
                    : false;

                return Container(
                  decoration: BoxDecoration(
                    color: context.colorScheme.surface,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(isExpanded ? 0 : AppSpacing.radius24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 16,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Header Section (Fixed at top)
                      GestureDetector(
                        onTap: _toggleExpand,
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: AppSpacing.space16,
                            right: AppSpacing.space16,
                            top: isExpanded ? MediaQuery.of(context).padding.top : 0,
                          ),
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
                              AnimatedCrossFade(
                                duration: const Duration(milliseconds: 150),
                                crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                                firstChild: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        children: [
                                          const Gap(AppSpacing.space8),
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
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      'Venda ${vm.saleNumber}',
                                                      style: context.textTheme.titleSmall?.copyWith(
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                    Text(
                                                      '${vm.totalItems} ${vm.totalItems == 1 ? 'item' : 'itens'}',
                                                      style: context.textTheme.bodySmall,
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Gap(AppSpacing.space8),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          currencyFormat.format(vm.total),
                                          style: context.textTheme.titleLarge?.copyWith(
                                            color: context.colorScheme.primary,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        const Gap(AppSpacing.space4),
                                        Icon(
                                          Icons.keyboard_arrow_up_rounded,
                                          color: context.colorScheme.primary,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                secondChild: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Carrinho',
                                          style: context.textTheme.titleLarge,
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              'Venda ',
                                              style: context.textTheme.bodySmall,
                                            ),
                                            Text(
                                              vm.saleNumber,
                                              style: context.textTheme.bodySmall?.copyWith(
                                                color: context.colorScheme.primary,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              ' • ${vm.totalItems} ${vm.totalItems == 1 ? 'item' : 'itens'}',
                                              style: context.textTheme.bodySmall,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: context.colorScheme.primary,
                                    ),
                                  ],
                                ),
                              ),
                              const Gap(AppSpacing.space8),
                            ],
                          ),
                        ),
                      ),

                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: isExpanded ? 1.0 : 0.0,
                        child: const Divider(height: 1),
                      ),

                      // Cart Items List (Scrollable middle section)
                      Expanded(
                        child: ListView.separated(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.space16,
                            vertical: AppSpacing.space8,
                          ),
                          itemCount: vm.items.length,
                          separatorBuilder: (context, index) => const Gap(AppSpacing.space8),
                          itemBuilder: (context, index) {
                            final cartItem = vm.items[index];
                            return CartItemTile(
                              item: cartItem,
                              onIncrease: () => vm.increaseQty(cartItem.product.id),
                              onDecrease: () => vm.decreaseQty(cartItem.product.id),
                              onRemove: () => vm.removeProduct(cartItem.product.id),
                            );
                          },
                        ),
                      ),

                      // Summary & Checkout Button (Fixed at bottom)
                      Visibility(
                        visible: isExpanded,
                        maintainState: true,
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: AppSpacing.space16,
                            right: AppSpacing.space16,
                            top: AppSpacing.space12,
                            bottom: MediaQuery.of(context).padding.bottom + AppSpacing.space16,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CartSummaryWidget(
                                total: vm.total,
                              ),
                              const Gap(AppSpacing.space16),
                              AppButton(
                                label: 'Finalizar venda',
                                isFullWidth: true,
                                onPressed: () {},
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
