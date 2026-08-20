import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_status.dart';
import 'package:estoque_pro/app/features/sales/presentation/widgets/sheets/digital_invoice_sheet.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class SaleCardHeader extends StatelessWidget {
  final SaleEntity sale;

  const SaleCardHeader({
    super.key,
    required this.sale,
  });

  Color _getStatusColor(SaleStatus status) => switch (status) {
    SaleStatus.inProgress => AppColors.warning,
    SaleStatus.completed => AppColors.success,
    SaleStatus.cancelled => AppColors.error,
    SaleStatus.returned => AppColors.warning,
    SaleStatus.exchanged => AppColors.warning,
    SaleStatus.corrected => AppColors.warning,
    SaleStatus.edited => AppColors.warning,
  };

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final statusColor = _getStatusColor(sale.status);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Venda ${sale.saleNumber}',
              style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              dateFormat.format(sale.createdAt),
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTag(title: sale.status.label, color: statusColor),
            if (sale.status != SaleStatus.inProgress) ...[
              const Gap(AppSpacing.space4),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  Icons.receipt_long_rounded,
                  size: AppSpacing.icon20,
                  color: context.colorScheme.primary,
                ),
                tooltip: 'Comprovante de Venda',
                onPressed: () => DigitalInvoiceSheet.show(context, sale),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
