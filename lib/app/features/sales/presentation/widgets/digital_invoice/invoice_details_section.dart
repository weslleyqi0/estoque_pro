import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/core/utils/currency_input_formatter.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/payment_method.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_status.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import 'invoice_info_row.dart';

class InvoiceDetailsSection extends StatelessWidget {
  final SaleEntity sale;

  const InvoiceDetailsSection({
    super.key,
    required this.sale,
  });

  IconData _getPaymentIcon(PaymentMethod method) {
    return switch (method) {
      PaymentMethod.dinheiro => AppIcons.currency,
      PaymentMethod.pix => AppIcons.pix,
      PaymentMethod.credito => AppIcons.creditCard,
      PaymentMethod.debito => AppIcons.creditScore,
      PaymentMethod.fiado => AppIcons.receiptLong,
    };
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final amountPaid = sale.amountPaid ?? 0.0;
    final change = (sale.change ?? 0.0).clamp(0.0, double.infinity);

    return Column(
      crossAxisAlignment: .start,
      children: [
        InvoiceInfoRow(label: 'Nº da Venda:', value: sale.saleNumber, isBold: true),
        InvoiceInfoRow(label: 'Data & Hora:', value: dateFormat.format(sale.createdAt)),
        InvoiceInfoRow(label: 'Vendedor:', value: sale.userName),
        InvoiceInfoRow(
          label: 'Cliente:',
          value: sale.customerName?.isNotEmpty == true ? sale.customerName! : 'Não informado',
        ),

        // Payment Row with Icon
        Padding(
          padding: const .symmetric(vertical: 3),
          child: Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              Text(
                'Forma de Pagamento:',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
              Row(
                mainAxisSize: .min,
                children: [
                  Icon(
                    _getPaymentIcon(sale.paymentMethod),
                    size: AppSpacing.icon16,
                    color: context.colorScheme.primary,
                  ),
                  const Gap(4),
                  Text(
                    sale.paymentMethod.label,
                    style: context.textTheme.bodySmall?.copyWith(
                      fontWeight: .bold,
                      color: context.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        if (sale.paymentMethod == PaymentMethod.dinheiro && amountPaid > 0) ...[
          InvoiceInfoRow(
            label: 'Valor Recebido:',
            value: CurrencyInputFormatter.formatCurrency(amountPaid),
          ),
          InvoiceInfoRow(
            label: 'Troco:',
            value: CurrencyInputFormatter.formatCurrency(change),
            valueColor: AppColors.success,
            isBold: true,
          ),
        ],

        InvoiceInfoRow(
          label: 'Status:',
          value: sale.status.label,
          valueColor: sale.status == SaleStatus.completed
              ? AppColors.success
              : sale.status == SaleStatus.cancelled
              ? AppColors.error
              : AppColors.warning,
          isBold: true,
        ),
      ],
    );
  }
}
