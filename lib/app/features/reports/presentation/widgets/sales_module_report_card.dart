import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/core/router/app_routes.dart';
import 'package:estoque_pro/app/features/reports/domain/entities/sales_report_entity.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class SalesModuleReportCard extends StatelessWidget {
  final SalesReportEntity salesReport;

  const SalesModuleReportCard({
    super.key,
    required this.salesReport,
  });

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Container(
      padding: const EdgeInsets.all(AppSpacing.space16),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radius16),
        border: Border.all(
          color: context.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.space12),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppSpacing.radius8),
                    ),
                    child: const Icon(
                      Icons.point_of_sale_outlined,
                      color: Colors.green,
                      size: AppSpacing.icon20,
                    ),
                  ),
                  const Gap(AppSpacing.space12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Desempenho de Vendas',
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${salesReport.salesCount} vendas finalizadas',
                        style: context.textTheme.labelSmall?.copyWith(
                          color: context.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              AppIconButton.primary(
                icon: Icons.arrow_forward_ios,
                size: AppIconButtonSize.small,
                iconColor: context.colorScheme.onSurface.withValues(alpha: 0.6),
                tooltip: 'Ver vendas',
                onPressed: () => context.push(AppRoutes.sales),
              ),
            ],
          ),

          const Gap(AppSpacing.space16),

          // Painel com detalhes
          Container(
            padding: const EdgeInsets.all(AppSpacing.space12),
            decoration: BoxDecoration(
              color: context.colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(AppSpacing.radius12),
              border: Border.all(
                color: context.colorScheme.outlineVariant.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: [
                _RowMetric(
                  label: 'Ticket Médio',
                  value: currency.format(salesReport.averageTicket),
                  color: context.colorScheme.primary,
                  isBold: true,
                ),
                const Divider(height: 16),
                _RowMetric(
                  label: 'Margem de Lucro',
                  value: '${salesReport.marginPercent.toStringAsFixed(1)}%',
                  color: AppColors.success,
                ),
                const Divider(height: 16),
                _RowMetric(
                  label: 'Descontos Concedidos',
                  value: currency.format(salesReport.totalDiscount),
                  color: Colors.orange,
                ),
                const Divider(height: 16),
                _RowMetric(
                  label: 'Vendas no Fiado',
                  value: salesReport.fiadoSalesCount > 0
                      ? '${salesReport.fiadoSalesCount} (${currency.format(salesReport.fiadoAmount)})'
                      : '0',
                  color: salesReport.fiadoSalesCount > 0 ? Colors.pink : null,
                ),
                const Divider(height: 16),
                _RowMetric(
                  label: 'Vendas Canceladas',
                  value: '${salesReport.cancelledSalesCount}',
                  color: salesReport.cancelledSalesCount > 0 ? AppColors.error : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RowMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  final bool isBold;

  const _RowMetric({
    required this.label,
    required this.value,
    this.color,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ),
        Text(
          value,
          style: context.textTheme.bodyMedium?.copyWith(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: color ?? context.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
