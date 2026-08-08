import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/core/utils/currency_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Subtotal', style: context.textTheme.bodyMedium),
              Text(
                CurrencyInputFormatter.formatCurrency(subtotal!),
                style: context.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        if (hasDiscount) ...[
          if (hasSubtotal) const Gap(4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Desconto', style: context.textTheme.bodyMedium?.copyWith(color: AppColors.error)),
              Text(
                '- ${CurrencyInputFormatter.formatCurrency(discount!)}',
                style: context.textTheme.bodyMedium?.copyWith(color: AppColors.error, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
        if (hasSubtotal || hasDiscount)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Total', style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            Text(
              CurrencyInputFormatter.formatCurrency(total),
              style: context.textTheme.headlineSmall?.copyWith(
                color: context.colorScheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
