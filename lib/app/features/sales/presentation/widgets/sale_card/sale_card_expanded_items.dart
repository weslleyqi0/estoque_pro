import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/core/utils/currency_input_formatter.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_entity.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class SaleCardExpandedItems extends StatelessWidget {
  final SaleEntity sale;

  const SaleCardExpandedItems({
    super.key,
    required this.sale,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: AppSpacing.space16),
        Text(
          'Produtos Vendidos',
          style: context.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const Gap(8),
        ...sale.items.map(
          (item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${item.quantity}x  ${item.productName}',
                    style: context.textTheme.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Gap(AppSpacing.space4),
                Text(
                  CurrencyInputFormatter.formatCurrency(item.totalPrice),
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const Divider(height: AppSpacing.space24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Subtotal', style: context.textTheme.bodySmall),
            Text(CurrencyInputFormatter.formatCurrency(sale.subtotal), style: context.textTheme.bodySmall),
          ],
        ),
        if (sale.calculatedDiscount > 0)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(sale.discountLabel, style: context.textTheme.bodySmall?.copyWith(color: AppColors.error)),
              Text(
                '- ${CurrencyInputFormatter.formatCurrency(sale.calculatedDiscount)}',
                style: context.textTheme.bodySmall?.copyWith(color: AppColors.error),
              ),
            ],
          ),
        const Gap(AppSpacing.space4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Vendedor', style: context.textTheme.bodySmall),
            Text(
              sale.userName,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
