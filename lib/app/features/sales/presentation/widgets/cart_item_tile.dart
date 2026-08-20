import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/core/utils/currency_input_formatter.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/cart_item.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class CartItemTile extends StatelessWidget {
  final CartItem item;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;

  const CartItemTile({
    super.key,
    required this.item,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const .symmetric(horizontal: AppSpacing.space4, vertical: AppSpacing.space8),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSpacing.radius12),
      ),
      child: Row(
        children: [
          // Image
          AppNetworkImage(
            imageUrl: item.product.imgUrl,
            size: 52,
            borderRadius: AppSpacing.borderRadius8,
          ),
          const Gap(AppSpacing.space12),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(
                  item.product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, height: 0.9),
                ),
                Text('${CurrencyInputFormatter.formatCurrency(item.product.price)} un.', style: context.textTheme.bodySmall),
                Text(
                  'Total: ${CurrencyInputFormatter.formatCurrency(item.totalPrice)}',
                  style: context.textTheme.labelMedium?.copyWith(
                    color: context.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (item.quantity > 1)
                AppIconButton.outlined(
                  onPressed: onDecrease,
                  size: AppIconButtonSize.medium,
                  icon: AppIcons.remove,
                  iconColor: AppColors.errorDark,
                  backgroundColor: context.colorScheme.error.withValues(alpha: 0.3),
                )
              else
                AppIconButton.outlined(
                  onPressed: onRemove,
                  size: AppIconButtonSize.medium,
                  icon: AppIcons.delete,
                  iconColor: AppColors.errorDark,
                  backgroundColor: context.colorScheme.error.withValues(alpha: 0.3),
                ),
              SizedBox(
                width: 28,
                child: Text(
                  '${item.quantity}',
                  textAlign: TextAlign.center,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              AppIconButton.outlined(
                size: AppIconButtonSize.medium,
                onPressed: item.quantity >= item.product.stock ? null : onIncrease,
                icon: AppIcons.add,
                backgroundColor: context.colorScheme.primary.withValues(alpha: 0.3),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
