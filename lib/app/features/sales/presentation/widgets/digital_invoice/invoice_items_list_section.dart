import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/core/utils/currency_input_formatter.dart';
import 'package:estoque_pro/app/core/utils/list_extensions.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_entity.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class InvoiceItemsListSection extends StatelessWidget {
  final SaleEntity sale;

  const InvoiceItemsListSection({
    super.key,
    required this.sale,
  });

  @override
  Widget build(BuildContext context) {
    final sortedItems = sale.items.sortedByName((item) => item.productName);

    return Column(
      crossAxisAlignment: .start,
      children: [
        Row(
          mainAxisAlignment: .spaceBetween,
          children: [
            Text(
              'ITENS DA COMPRA',
              style: context.textTheme.labelLarge?.copyWith(
                fontWeight: .bold,
                color: context.colorScheme.primary,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              '${sale.totalItems} ${sale.totalItems == 1 ? 'item' : 'itens'}',
              style: context.textTheme.labelLarge,
            ),
          ],
        ),
        const Gap(AppSpacing.space8),
        ...List.generate(sortedItems.length, (index) {
          final item = sortedItems[index];
          return Padding(
            padding: const .symmetric(vertical: 2),
            child: Row(
              crossAxisAlignment: .start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      Text(
                        item.productName,
                        style: context.textTheme.bodyMedium?.copyWith(
                          fontWeight: .bold,
                        ),
                      ),
                      Text(
                        '${item.quantity} x ${CurrencyInputFormatter.formatCurrency(item.unitPrice)}',
                        style: context.textTheme.labelLarge?.copyWith(
                          color: context.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(AppSpacing.space8),
                Text(
                  CurrencyInputFormatter.formatCurrency(item.totalPrice),
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: .bold,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
