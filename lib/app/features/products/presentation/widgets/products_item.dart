import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/core/router/app_routes.dart';
import 'package:estoque_pro/app/core/utils/currency_input_formatter.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_entity.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

class ProductsItem extends StatelessWidget {
  final ProductEntity product;

  const ProductsItem({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final maxProgress = product.minStock > 0 ? (product.minStock * 2).toDouble() : 10.0;
    final rawProgress = maxProgress > 0 ? product.stock / maxProgress : 0.0;
    final progressValue = rawProgress.clamp(0.0, 1.0);

    Color statusColor;
    if (rawProgress < 0.25) {
      statusColor = AppColors.error;
    } else if (rawProgress < 0.50) {
      statusColor = AppColors.warning;
    } else if (rawProgress < 0.75) {
      statusColor = AppColors.success;
    } else {
      statusColor = AppColors.primary;
    }

    final textColor = !product.isActive ? context.colorScheme.onSurface.withValues(alpha: 0.4) : null;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.space16),
        side: BorderSide(
          color: rawProgress < 0.50 ? statusColor : context.colorScheme.outline,
          width: 0.8,
        ),
      ),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.space16),
        overlayColor: WidgetStateProperty.all(statusColor.withValues(alpha: 0.1)),
        onTap: () {
          context.push(AppRoutes.productForm, extra: product);
        },
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.space12),
          child: Row(
            children: [
              Container(
                height: 110,
                width: 110,
                decoration: BoxDecoration(
                  color: context.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppSpacing.space16),
                ),
                clipBehavior: Clip.hardEdge,
                child: product.imgUrl.isNotEmpty
                    ? Image.network(
                        product.imgUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(
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
              const Gap(AppSpacing.space16),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                product.name,
                                overflow: TextOverflow.ellipsis,
                                style: context.textTheme.titleLarge?.copyWith(color: textColor),
                              ),
                              Text(
                                product.categories.isEmpty
                                    ? 'Sem categoria'
                                    : product.categories.map((category) => category.name).join(', '),
                                overflow: TextOverflow.ellipsis,
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: textColor,
                                  height: 0.9,
                                ),
                              ),
                              Row(
                                crossAxisAlignment: .center,
                                children: [
                                  Text(
                                    'R\$ ',
                                    style: context.textTheme.bodyLarge?.copyWith(
                                      color: textColor?.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  Text(
                                    CurrencyInputFormatter.formatDouble(product.price),
                                    style: context.textTheme.headlineMedium?.copyWith(
                                      color: textColor?.withValues(alpha: 0.5),
                                      fontWeight: FontWeight.w900,
                                      height: 0.9,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: .spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Estoque: ${product.stock}',
                                  style: context.textTheme.bodyMedium?.copyWith(
                                    color: rawProgress < 0.50 ? statusColor : null,
                                    fontWeight: rawProgress < 0.50 ? FontWeight.bold : null,
                                  ),
                                ),
                                if (rawProgress < 0.50) ...[
                                  const Gap(AppSpacing.space4),
                                  Icon(
                                    rawProgress < 0.25 ? Symbols.cancel_rounded : Symbols.info_rounded,
                                    size: AppSpacing.icon16,
                                    color: statusColor,
                                    weight: 900,
                                  ),
                                ],
                              ],
                            ),
                            Text(
                              'Min: ${product.minStock}',
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: rawProgress < 0.50 ? statusColor : null,
                                fontWeight: rawProgress < 0.50 ? FontWeight.bold : null,
                              ),
                            ),
                          ],
                        ),
                        LinearProgressIndicator(
                          value: progressValue,
                          borderRadius: AppSpacing.borderRadius4,
                          backgroundColor: statusColor.withValues(alpha: 0.2),
                          color: statusColor,
                          minHeight: 8,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
