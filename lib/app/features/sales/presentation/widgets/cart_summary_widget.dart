import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/core/utils/currency_input_formatter.dart';
import 'package:flutter/material.dart';

class CartSummaryWidget extends StatelessWidget {
  final double? subtotal;
  final double? discount;
  final double total;

  const CartSummaryWidget({
    super.key,
    this.subtotal,
    this.discount,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final hasSubtotal = subtotal != null;
    final hasDiscount = discount != null && discount! > 0;

    return Column(
      children: [
        if (hasSubtotal)
          Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              Text('Subtotal', style: context.textTheme.bodyMedium),
              Text(
                CurrencyInputFormatter.formatCurrency(subtotal!),
                style: context.textTheme.bodyMedium?.copyWith(fontWeight: .w700),
              ),
            ],
          ),
        if (hasDiscount) ...[
          Builder(
            builder: (context) {
              String discountLabel = 'Desconto';
              if (hasSubtotal && subtotal! > 0) {
                final pct = (discount! / subtotal!) * 100;
                final pctStr = pct % 1 == 0 ? pct.toInt().toString() : pct.toStringAsFixed(1);
                discountLabel = 'Desconto ($pctStr%)';
              }
              return Row(
                mainAxisAlignment: .spaceBetween,
                children: [
                  Text(discountLabel, style: context.textTheme.bodySmall?.copyWith(color: AppColors.error)),
                  Text(
                    '- ${CurrencyInputFormatter.formatCurrency(discount!)}',
                    style: context.textTheme.labelLarge?.copyWith(color: AppColors.error, fontWeight: .w600),
                  ),
                ],
              );
            },
          ),
        ],
        if (hasSubtotal || hasDiscount)
          Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.space4),
            child: Divider(),
          ),
        Row(
          mainAxisAlignment: .spaceBetween,
          children: [
            Text('Total', style: context.textTheme.titleMedium?.copyWith(fontWeight: .bold)),
            Text(
              CurrencyInputFormatter.formatCurrency(total),
              style: context.textTheme.titleLarge?.copyWith(
                color: context.colorScheme.primary,
                fontWeight: .w800,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
