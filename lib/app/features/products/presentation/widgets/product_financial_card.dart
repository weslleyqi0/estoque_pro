import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/core/utils/currency_input_formatter.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_entity.dart';
import 'package:estoque_pro/app/features/products/presentation/widgets/info_row.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class ProductFinancialCard extends StatelessWidget {
  final ProductEntity product;

  const ProductFinancialCard({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final unitProfit = product.unitProfit;
    final isProfitPositive = unitProfit >= 0;
    final marginFormatted = product.marginPercent.toStringAsFixed(1);
    final projectedProfit = product.totalProjectedProfit;
    final isProjectedPositive = projectedProfit >= 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.attach_money,
              size: AppSpacing.icon20,
              color: context.colorScheme.primary,
            ),
            const Gap(AppSpacing.space8),
            Text(
              'Rentabilidade & Estoque',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const Gap(AppSpacing.space8),
        Card(
          color: context.colorScheme.surfaceContainerLow,
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadius16,
            side: BorderSide(color: context.colorScheme.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cost price & Selling price
                InfoRow(
                  label: 'Preço de Custo (Unitário)',
                  value: CurrencyInputFormatter.formatCurrency(product.costPrice),
                ),
                const Gap(AppSpacing.space12),
                InfoRow(
                  label: 'Preço de Venda (Unitário)',
                  value: CurrencyInputFormatter.formatCurrency(product.price),
                ),
                const Gap(AppSpacing.space12),
                InfoRow(
                  label: 'Lucro Unitário',
                  value: '${CurrencyInputFormatter.formatCurrency(unitProfit)} ($marginFormatted%)',
                  warningColor: isProfitPositive ? context.colorScheme.primary : context.colorScheme.error,
                ),

                const Divider(height: AppSpacing.space24),

                // Stock metrics
                InfoRow(
                  label: 'Total em Estoque (a Custo)',
                  value: CurrencyInputFormatter.formatCurrency(product.totalCostStock),
                ),
                const Gap(AppSpacing.space12),
                InfoRow(
                  label: 'Total em Estoque (a Venda)',
                  value: CurrencyInputFormatter.formatCurrency(product.totalSellingStock),
                ),
                const Gap(AppSpacing.space12),
                InfoRow(
                  label: 'Lucro Previsto no Estoque',
                  value: CurrencyInputFormatter.formatCurrency(projectedProfit),
                  warningColor: isProjectedPositive ? context.colorScheme.primary : context.colorScheme.error,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
