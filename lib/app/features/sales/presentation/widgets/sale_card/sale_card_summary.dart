import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/core/utils/currency_input_formatter.dart';
import 'package:estoque_pro/app/features/deliveries/domain/entities/delivery_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_entity.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class SaleCardSummary extends StatelessWidget {
  final SaleEntity sale;
  final DeliveryEntity? delivery;
  final bool isExpanded;

  const SaleCardSummary({
    super.key,
    required this.sale,
    this.delivery,
    required this.isExpanded,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${sale.totalItems} ${sale.totalItems == 1 ? 'item' : 'itens'} • ${sale.paymentMethod.label}',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  CurrencyInputFormatter.formatCurrency(sale.total),
                  style: context.textTheme.titleMedium?.copyWith(
                    color: context.colorScheme.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Gap(AppSpacing.space4),
                Icon(
                  isExpanded ? AppIcons.arrowUp : AppIcons.arrowDown,
                  color: context.colorScheme.primary,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
