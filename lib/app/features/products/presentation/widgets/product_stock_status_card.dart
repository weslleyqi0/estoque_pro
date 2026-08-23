import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_entity.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class ProductStockStatusCard extends StatelessWidget {
  final ProductEntity product;
  final String statusText;
  final Color statusColor;
  final IconData statusIcon;
  final VoidCallback? onAdjustPressed;

  const ProductStockStatusCard({
    super.key,
    required this.product,
    required this.statusText,
    required this.statusColor,
    required this.statusIcon,
    this.onAdjustPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Status do Estoque', style: context.textTheme.titleMedium),
        const Gap(AppSpacing.space8),
        Card(
          elevation: 0,
          color: statusColor.withValues(alpha: 0.1),
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadius24,
            side: BorderSide(color: statusColor),
          ),
          borderOnForeground: true,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.space12),
            child: Row(
              children: [
                Icon(
                  statusIcon,
                  color: statusColor,
                  size: AppSpacing.icon40,
                  weight: 500,
                ),
                const Gap(AppSpacing.space8),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        statusText,
                        style: context.textTheme.titleMedium?.copyWith(
                          color: statusColor,
                        ),
                      ),
                      Text(
                        'Em estoque: ${product.stock} un. / Mínimo: ${product.minStock} un.',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colorScheme.onSurface.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                if (onAdjustPressed != null) ...[
                  const Gap(AppSpacing.space8),
                  AppButton(
                    onPressed: onAdjustPressed,
                    backgroundColor: AppColors.surfaceLight,
                    borderRadius: AppSpacing.borderRadius24,
                    child: Text(
                      'Ajustar',
                      style: context.textTheme.titleMedium?.copyWith(color: AppColors.textPrimaryLight),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
