import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/core/utils/currency_input_formatter.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_entity.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import 'invoice_info_row.dart';

class InvoiceFinancialSummary extends StatelessWidget {
  final SaleEntity sale;

  const InvoiceFinancialSummary({
    super.key,
    required this.sale,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        InvoiceInfoRow(label: 'Qtd. Total de Itens:', value: '${sale.totalItems}'),
        InvoiceInfoRow(
          label: 'Subtotal:',
          value: CurrencyInputFormatter.formatCurrency(sale.subtotal),
        ),
        if (sale.calculatedDiscount > 0)
          InvoiceInfoRow(
            label: '${sale.discountLabel}:',
            value: '- ${CurrencyInputFormatter.formatCurrency(sale.calculatedDiscount)}',
            valueColor: AppColors.error,
            isBold: true,
          ),
        const Gap(AppSpacing.space8),
        Container(
          padding: const .all(AppSpacing.space12),
          decoration: BoxDecoration(
            color: context.colorScheme.outline.withValues(alpha: 0.6),
            borderRadius: .circular(AppSpacing.radius12),
            border: .all(color: context.colorScheme.outline),
          ),
          child: Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              Text(
                'TOTAL DA VENDA',
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: .w900,
                ),
              ),
              Text(
                CurrencyInputFormatter.formatCurrency(sale.total),
                style: context.textTheme.headlineSmall?.copyWith(
                  color: context.colorScheme.primary,
                  fontWeight: .w900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
