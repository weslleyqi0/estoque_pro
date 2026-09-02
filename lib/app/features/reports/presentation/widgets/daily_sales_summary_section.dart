import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/features/reports/domain/entities/sales_report_entity.dart';
import 'package:estoque_pro/app/features/reports/presentation/widgets/report_kpi_card.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class DailySalesSummarySection extends StatelessWidget {
  final SalesReportEntity salesReport;
  final String periodName;

  const DailySalesSummarySection({
    super.key,
    required this.salesReport,
    required this.periodName,
  });

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Resumo de Vendas ($periodName)',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${salesReport.salesCount} vendas',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const Gap(AppSpacing.space12),

        // Grid com as métricas financeiras principais
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.space8,
          crossAxisSpacing: AppSpacing.space8,
          childAspectRatio: 1.6,
          children: [
            ReportKpiCard(
              title: 'Total em Vendas',
              value: currency.format(salesReport.totalSales),
              subtitle: 'Faturamento bruto',
              icon: Icons.payments_outlined,
              color: context.colorScheme.primary,
            ),
            ReportKpiCard(
              title: 'Lucro Estimado',
              value: currency.format(salesReport.grossProfit),
              subtitle: 'Margem: ${salesReport.marginPercent.toStringAsFixed(1)}%',
              icon: Icons.trending_up,
              color: AppColors.success,
            ),
            ReportKpiCard(
              title: 'Custo dos Produtos',
              value: currency.format(salesReport.totalCost),
              subtitle: 'Mercadorias vendidas',
              icon: Icons.inventory_2_outlined,
              color: Colors.brown,
            ),
            ReportKpiCard(
              title: 'Fiados',
              value: currency.format(salesReport.fiadoAmount),
              subtitle: 'A receber a prazo',
              icon: Icons.pending_actions,
              color: Colors.pink,
            ),
            ReportKpiCard(
              title: 'No Cartão',
              value: currency.format(salesReport.cardTotalAmount),
              subtitle: 'Crédito + Débito',
              icon: Icons.credit_card,
              color: Colors.teal,
            ),
            ReportKpiCard(
              title: 'Em Dinheiro',
              value: currency.format(salesReport.cashAmount),
              subtitle: 'Recebido em espécie',
              icon: Icons.attach_money,
              color: Colors.green,
            ),
          ],
        ),
      ],
    );
  }
}
