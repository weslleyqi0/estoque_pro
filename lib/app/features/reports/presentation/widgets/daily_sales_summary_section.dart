import 'dart:math' as math;

import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/features/reports/domain/entities/sales_report_entity.dart';
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
    final totalSales = salesReport.totalSales;
    final hasData = totalSales > 0;

    // Fatias de Formas de Pagamento
    final allPaymentSlices = [
      _PieSliceData(label: 'Dinheiro', amount: salesReport.cashAmount, color: Colors.green),
      _PieSliceData(label: 'Cartão', amount: salesReport.cardTotalAmount, color: Colors.teal),
      _PieSliceData(label: 'Fiados', amount: salesReport.fiadoAmount, color: Colors.pink),
      _PieSliceData(label: 'PIX', amount: salesReport.pixAmount, color: Colors.deepPurpleAccent),
    ];
    final activePaymentSlices = allPaymentSlices.where((s) => s.amount > 0).toList();
    final paymentDisplaySlices = activePaymentSlices.isNotEmpty ? activePaymentSlices : allPaymentSlices;

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
          // Header da Seção
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.space12),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.radius8),
                ),
                child: const Icon(
                  Icons.pie_chart_outline_rounded,
                  color: Colors.deepPurple,
                  size: AppSpacing.icon20,
                ),
              ),
              const Gap(AppSpacing.space12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Resumo de Vendas',
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '$periodName • ${salesReport.salesCount} vendas',
                    style: context.textTheme.labelSmall?.copyWith(
                      color: context.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const Gap(AppSpacing.space16),

          if (!hasData) ...[
            SizedBox(
              height: 120,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.pie_chart_outline,
                      size: 40,
                      color: context.colorScheme.outline.withValues(alpha: 0.4),
                    ),
                    const Gap(AppSpacing.space8),
                    Text(
                      'Nenhuma venda registrada no período selecionado',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            // Gráfico em Row: Formas de Pagamento
            _DonutSummaryRow(
              title: 'Formas de Pagamento',
              centerTitle: 'Total',
              centerValue: currency.format(totalSales),
              slices: activePaymentSlices,
              displaySlices: paymentDisplaySlices,
              total: totalSales,
              currency: currency,
            ),

            const Gap(AppSpacing.space16),

            // Rodapé com resumo financeiro complementar (Lucro e Custo)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.space12,
                vertical: AppSpacing.space8,
              ),
              decoration: BoxDecoration(
                color: context.colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(AppSpacing.radius12),
                border: Border.all(
                  color: context.colorScheme.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.trending_up,
                        size: AppSpacing.icon16,
                        color: AppColors.success,
                      ),
                      const Gap(AppSpacing.space8),
                      Text(
                        'Lucro: ${currency.format(salesReport.grossProfit)}',
                        style: context.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                      const Gap(AppSpacing.space4),
                      Text(
                        '(${salesReport.marginPercent.toStringAsFixed(1)}%)',
                        style: context.textTheme.labelSmall?.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.inventory_2_outlined,
                        size: AppSpacing.icon16,
                        color: Colors.brown,
                      ),
                      const Gap(AppSpacing.space8),
                      Text(
                        'Custo: ${currency.format(salesReport.totalCost)}',
                        style: context.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.brown,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DonutSummaryRow extends StatelessWidget {
  final String title;
  final String centerTitle;
  final String centerValue;
  final List<_PieSliceData> slices;
  final List<_PieSliceData> displaySlices;
  final double total;
  final NumberFormat currency;

  const _DonutSummaryRow({
    required this.title,
    required this.centerTitle,
    required this.centerValue,
    required this.slices,
    required this.displaySlices,
    required this.total,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Gráfico Donut
        SizedBox(
          width: 120,
          height: 120,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(120, 120),
                painter: _DonutChartPainter(
                  slices: slices,
                  total: total,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    centerTitle,
                    style: context.textTheme.labelSmall?.copyWith(
                      color: context.colorScheme.onSurface.withValues(alpha: 0.6),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    centerValue,
                    style: context.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),

        const Gap(AppSpacing.space16),

        // Título e Lista de Valores
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(AppSpacing.space8),
              ...displaySlices.map((slice) {
                final percent = total > 0 ? (slice.amount / total) * 100 : 0.0;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: slice.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const Gap(AppSpacing.space4),
                      Expanded(
                        child: Text(
                          slice.label,
                          style: context.textTheme.bodySmall?.copyWith(
                            fontSize: 11,
                            color: context.colorScheme.onSurface.withValues(alpha: 0.8),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        currency.format(slice.amount),
                        style: context.textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Gap(AppSpacing.space4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: slice.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppSpacing.radius8),
                        ),
                        child: Text(
                          '${percent.toStringAsFixed(0)}%',
                          style: context.textTheme.labelSmall?.copyWith(
                            color: slice.color,
                            fontWeight: FontWeight.bold,
                            fontSize: 9,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}

class _PieSliceData {
  final String label;
  final double amount;
  final Color color;

  const _PieSliceData({
    required this.label,
    required this.amount,
    required this.color,
  });
}

class _DonutChartPainter extends CustomPainter {
  final List<_PieSliceData> slices;
  final double total;

  const _DonutChartPainter({
    required this.slices,
    required this.total,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 20.0;

    if (total <= 0 || slices.isEmpty) {
      final emptyPaint = Paint()
        ..color = Colors.grey.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;
      canvas.drawCircle(center, radius - strokeWidth / 2, emptyPaint);
      return;
    }

    // Se houver apenas uma fatia com 100%, desenha o círculo completo
    if (slices.length == 1) {
      final singlePaint = Paint()
        ..color = slices.first.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;
      canvas.drawCircle(center, radius - strokeWidth / 2, singlePaint);
      return;
    }

    final arcRadius = radius - strokeWidth / 2;
    final rect = Rect.fromCircle(center: center, radius: arcRadius);

    // Espaçamento constante de 4px entre segmentos
    const double desiredPixelGap = 4.0;

    final capAngle = (strokeWidth / 2) / arcRadius;
    final gapAngle = (capAngle * 2) + (desiredPixelGap / arcRadius);

    // Ângulo total disponível após descontar os espaçamentos uniformes
    final totalGaps = gapAngle * slices.length;
    final availableAngle = math.max(2 * math.pi - totalGaps, 0.5);

    double currentAngle = -math.pi / 2; // Inicia às 12 horas

    for (final slice in slices) {
      final sweepAngle = (slice.amount / total) * availableAngle;

      final paint = Paint()
        ..color = slice.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(rect, currentAngle, math.max(sweepAngle, 0.02), false, paint);

      // Avança exatamente o arco desenhado + o gap constante idêntico para todos
      currentAngle += sweepAngle + gapAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.total != total || oldDelegate.slices != slices;
  }
}
