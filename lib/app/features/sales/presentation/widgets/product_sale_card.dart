import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/core/utils/currency_input_formatter.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_entity.dart';
import 'package:estoque_pro/app/features/products/presentation/extensions/product_stock_ui_extension.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:material_symbols_icons/symbols.dart';

class ProductSaleCard extends StatelessWidget {
  final ProductEntity product;
  final int cartQuantity;
  final VoidCallback onAdd;

  const ProductSaleCard({
    super.key,
    required this.product,
    required this.cartQuantity,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final stockStatusColor = product.stockStatusColor;

    return Card(
      color: context.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.borderRadius16,
        side: BorderSide(
          width: cartQuantity > 0 ? 1 : 0.5,
          color: cartQuantity > 0
              ? context.colorScheme.primary
              : context.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const .symmetric(horizontal: AppSpacing.radius12, vertical: AppSpacing.radius8),
        child: Row(
          children: [
            AppNetworkImage(imageUrl: product.imgUrl),
            const Gap(AppSpacing.space8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    product.categories.isNotEmpty ? product.categories.map((e) => e.name).join(', ') : 'Sem categoria',
                    style: context.textTheme.labelSmall?.copyWith(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    product.barcode.isNotEmpty ? product.barcode : 'Sem código',
                    style: context.textTheme.labelSmall?.copyWith(),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    mainAxisSize: .min,
                    children: [
                      Text(
                        CurrencyInputFormatter.formatCurrency(product.price),
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Gap(AppSpacing.space4),
                      Text(
                        '${product.stock} un.',
                        style: context.textTheme.titleSmall?.copyWith(
                          color: stockStatusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Gap(AppSpacing.space8),
            Badge(
              isLabelVisible: cartQuantity > 0,
              backgroundColor: AppColors.warning,
              label: Text(
                '$cartQuantity',
                style: context.textTheme.titleSmall?.copyWith(
                  color: context.colorScheme.onPrimary,
                ),
              ),
              child: AppButton(
                onPressed: onAdd,
                borderRadius: AppSpacing.borderRadius16,
                backgroundColor: cartQuantity >= product.stock
                    ? context.colorScheme.outline
                    : context.colorScheme.primaryContainer,
                child: const Icon(
                  Symbols.add_2_rounded,
                  color: AppColors.white,
                  size: AppSpacing.icon28,
                  weight: 600,
                ),
              ),
            ),
            const Gap(AppSpacing.space4),
          ],
        ),
      ),
    );
  }
}
