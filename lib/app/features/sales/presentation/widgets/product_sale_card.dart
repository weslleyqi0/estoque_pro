import 'package:cached_network_image/cached_network_image.dart';
import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/core/utils/currency_input_formatter.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_entity.dart';
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
            Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                color: context.colorScheme.onSurface.withValues(alpha: 0.05),
                borderRadius: AppSpacing.borderRadius16,
              ),
              foregroundDecoration: BoxDecoration(
                borderRadius: AppSpacing.borderRadius16,
                border: Border.all(
                  color: context.colorScheme.outline,
                  width: 0.5,
                ),
              ),
              clipBehavior: Clip.hardEdge,
              child: product.imgUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: product.imgUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      errorWidget: (context, url, error) => Icon(
                        Symbols.package_2_rounded,
                        size: AppSpacing.icon64,
                        weight: 300,
                        color: context.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    )
                  : Icon(
                      Symbols.package_2_rounded,
                      size: AppSpacing.icon64,
                      weight: 300,
                      color: context.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
            ),
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
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    product.categories.isNotEmpty ? product.categories.map((e) => e.name).join(', ') : 'Sem categoria',
                    style: context.textTheme.labelMedium?.copyWith(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    product.barcode.isNotEmpty ? product.barcode : 'Sem código',
                    style: context.textTheme.labelMedium?.copyWith(),
                    maxLines: 1,
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
                          color: product.stock <= product.minStock ? AppColors.error : context.colorScheme.outline,
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
                backgroundColor: context.colorScheme.primaryContainer,
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

  /* @override
  Widget build(BuildContext context) {

    final categoryName = product.categories.isNotEmpty ? product.categories.first.name : 'Geral';

    return Container(
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radius16),
        border: Border.all(
          color: cartQuantity > 0
              ? context.colorScheme.primary
              : context.colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: cartQuantity > 0 ? 1 : 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.space12),
            child: Row(
              children: [
                // Product Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.radius12),
                  child: Container(
                    width: 72,
                    height: 72,
                    color: context.colorScheme.surfaceContainerHighest,
                    child: product.imgUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: product.imgUrl,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => Icon(
                              Symbols.package_2_rounded,
                              color: context.colorScheme.onSurface.withValues(alpha: 0.5),
                              size: AppSpacing.icon48,
                            ),
                          )
                        : Icon(
                            Symbols.package_2_rounded,
                            color: context.colorScheme.onSurface.withValues(alpha: 0.5),
                            size: AppSpacing.icon48,
                          ),
                  ),
                ),
                const Gap(AppSpacing.space12),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        categoryName,
                        style: context.textTheme.labelMedium?.copyWith(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        product.barcode.isNotEmpty ? product.barcode : 'Sem código',
                        style: context.textTheme.labelMedium?.copyWith(),
                        maxLines: 1,
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
                              color: product.stock <= product.minStock ? AppColors.error : context.colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Gap(AppSpacing.space8),

                // Add button
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
                    backgroundColor: context.colorScheme.primaryContainer,
                    child: const Icon(
                      Symbols.add_2_rounded,
                      color: AppColors.white,
                      size: AppSpacing.icon28,
                      weight: 600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  } */
}
