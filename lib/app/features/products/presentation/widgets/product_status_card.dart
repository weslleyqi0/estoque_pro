import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_entity.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class ProductStatusCard extends StatelessWidget {
  final ProductEntity product;
  final ValueChanged<bool> onStatusChanged;

  const ProductStatusCard({
    super.key,
    required this.product,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Status do Produto', style: context.textTheme.titleMedium),
        const Gap(AppSpacing.space8),
        Card(
          color: context.colorScheme.surfaceContainerLow,
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadius16,
            side: BorderSide(color: context.colorScheme.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.space12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.space12),
                  decoration: BoxDecoration(
                    borderRadius: AppSpacing.borderRadius16,
                    color: product.isActive
                        ? AppColors.success.withValues(alpha: 0.1)
                        : context.colorScheme.onSurface.withValues(alpha: 0.1),
                  ),
                  child: Icon(
                    AppIcons.powerSettings,
                    color: product.isActive ? AppColors.success : context.colorScheme.onSurface.withValues(alpha: 0.5),
                    size: AppSpacing.icon32,
                    weight: 900,
                  ),
                ),
                const Gap(AppSpacing.space12),
                Flexible(
                  child: AppSwitchTitle(
                    title: product.isActive ? 'Produto Ativo' : 'Produto Desativado',
                    subtitle: product.isActive
                        ? 'Disponível para venda'
                        : product.isArchived
                        ? 'Arquivado (indisponível para venda)'
                        : 'Indisponível para venda',
                    value: product.isActive,
                    onChanged: onStatusChanged,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
