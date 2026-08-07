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
      statusColor = AppColors.info;
    }

    final textColor = !product.isActive ? context.colorScheme.onSurface.withValues(alpha: 0.4) : null;

    return Card(
      color: context.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.borderRadius16,
        side: BorderSide(color: context.colorScheme.outlineVariant),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radius16),
        overlayColor: WidgetStateProperty.all(statusColor.withValues(alpha: 0.1)),
        onTap: () {
          context.push(AppRoutes.productDetails, extra: product);
        },
        child: Padding(
          padding: const .all(AppSpacing.space8),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: .start,
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
                              child: SizedBox(
                                height: 80,
                                child: Column(
                                  mainAxisAlignment: .spaceBetween,
                                  crossAxisAlignment: .start,
                                  children: [
                                    Column(
                                      crossAxisAlignment: .start,
                                      children: [
                                        Text(
                                          product.name,
                                          overflow: TextOverflow.ellipsis,
                                          style: context.textTheme.titleMedium?.copyWith(color: textColor),
                                        ),
                                        Text(
                                          product.categories.isEmpty
                                              ? 'Sem categoria'
                                              : product.categories.map((category) => category.name).join(', '),
                                          overflow: TextOverflow.ellipsis,
                                          style: context.textTheme.labelMedium?.copyWith(
                                            color: textColor,
                                            height: 0.9,
                                          ),
                                        ),
                                      ],
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
                                          style: context.textTheme.headlineLarge?.copyWith(
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
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (rawProgress < 0.50) ...[
                    Icon(
                      product.stock <= 0 ? Symbols.cancel_rounded : Symbols.info_rounded,
                      size: AppSpacing.icon24,
                      color: statusColor,
                      weight: 900,
                    ),
                  ],
                ],
              ),
              const Gap(AppSpacing.space4),
              Padding(
                padding: const .symmetric(horizontal: AppSpacing.space4),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: .spaceBetween,
                      children: [
                        Text(
                          'Estoque: ${product.stock}',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: rawProgress < 0.50 ? statusColor : null,
                            fontWeight: rawProgress < 0.50 ? FontWeight.bold : null,
                          ),
                        ),
                        Text(
                          'Min: ${product.minStock}',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: rawProgress < 0.50 ? statusColor : null,
                            fontWeight: rawProgress < 0.50 ? FontWeight.bold : null,
                          ),
                        ),
                      ],
                    ),
                    LinearProgressIndicator(
                      value: progressValue,
                      borderRadius: AppSpacing.borderRadius4,
                      backgroundColor: context.colorScheme.outline,
                      color: statusColor,
                      minHeight: 10,
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
