import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/core/router/app_routes.dart';
import 'package:estoque_pro/app/features/reports/domain/entities/stock_report_entity.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class StockReportCard extends StatelessWidget {
  final StockReportEntity stockReport;

  const StockReportCard({
    super.key,
    required this.stockReport,
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
          // Header do Card
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.space8),
                    decoration: BoxDecoration(
                      color: context.colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppSpacing.radius8),
                    ),
                    child: Icon(
                      Icons.inventory_2_outlined,
                      color: context.colorScheme.primary,
                      size: AppSpacing.icon20,
                    ),
                  ),
                  const Gap(AppSpacing.space12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Produtos & Estoque',
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${stockReport.totalProducts} produtos (${stockReport.activeProducts} ativos)',
                        style: context.textTheme.labelSmall?.copyWith(
                          color: context.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios, size: 14),
                onPressed: () => context.push(AppRoutes.products),
                tooltip: 'Ver produtos',
              ),
            ],
          ),

          const Gap(AppSpacing.space16),

          // Alertas de estoque baixo e vazio
          Row(
            children: [
              Expanded(
                child: _StockAlertBadge(
                  label: 'Estoque Baixo',
                  count: stockReport.lowStockCount,
                  color: AppColors.warning,
                  icon: Icons.warning_amber_rounded,
                  onTap: () {
                    context.push(AppRoutes.products, extra: true);
                  },
                ),
              ),
              const Gap(AppSpacing.space8),
              Expanded(
                child: _StockAlertBadge(
                  label: 'Estoque Vazio',
                  count: stockReport.outOfStockCount,
                  color: AppColors.error,
                  icon: Icons.remove_circle_outline,
                  onTap: () {
                    context.push(AppRoutes.products, extra: 'empty_stock');
                  },
                ),
              ),
            ],
          ),

          const Gap(AppSpacing.space16),

          // Tabela/Grid de Métricas de Estoque
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
                _StockMetricRow(
                  label: 'Unidades em estoque',
                  value: '${stockReport.totalUnitsInStock} itens',
                  isBold: true,
                ),
                const Divider(height: 16),
                _StockMetricRow(
                  label: 'Valor de Custo (investido)',
                  value: currency.format(stockReport.totalCostStock),
                  color: Colors.brown,
                ),
                const Divider(height: 16),
                _StockMetricRow(
                  label: 'Faturamento Projetado',
                  value: currency.format(stockReport.totalSellingStock),
                  color: context.colorScheme.primary,
                ),
                const Divider(height: 16),
                _StockMetricRow(
                  label: 'Lucro Potencial Projetado',
                  value: currency.format(stockReport.totalProjectedProfit),
                  subtitle: 'Margem ${stockReport.projectedMarginPercent.toStringAsFixed(1)}%',
                  color: AppColors.success,
                  isBold: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StockAlertBadge extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _StockAlertBadge({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(AppSpacing.radius12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radius12),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space12,
            vertical: AppSpacing.space12,
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: AppSpacing.icon20),
              const Gap(AppSpacing.space8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$count',
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      label,
                      style: context.textTheme.labelSmall?.copyWith(
                        color: context.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StockMetricRow extends StatelessWidget {
  final String label;
  final String value;
  final String? subtitle;
  final Color? color;
  final bool isBold;

  const _StockMetricRow({
    required this.label,
    required this.value,
    this.subtitle,
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                color: color ?? context.colorScheme.onSurface,
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle!,
                style: context.textTheme.labelSmall?.copyWith(
                  color: color ?? context.colorScheme.onSurface.withValues(alpha: 0.6),
                  fontSize: 10,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
