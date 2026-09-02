import 'dart:math' as math;

import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/features/reports/domain/entities/sales_report_entity.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

enum _PieViewMode {
  payments('Formas de Pagamento'),
  profitCost('Lucro x Custo');

  final String label;
  const _PieViewMode(this.label);
}

class DailySalesSummarySection extends StatefulWidget {
  final SalesReportEntity salesReport;
  final String periodName;

  const DailySalesSummarySection({
    super.key,
    required this.salesReport,
    required this.periodName,
  });

  @override
  State<DailySalesSummarySection> createState() => _DailySalesSummarySectionState();
}

class _DailySalesSummarySectionState extends State<DailySalesSummarySection> {
  _PieViewMode _mode = _PieViewMode.payments;
  final NumberFormat _currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  @override
  Widget build(BuildContext context) {
    final report = widget.salesReport;
    final totalSales = report.totalSales;
    final hasData = totalSales > 0;

    // Fatias do gráfico de acordo com o modo selecionado
    final List<_PieSliceData> slices;
    if (_mode == _PieViewMode.payments) {
      slices = [
        if (report.cashAmount > 0)
          _PieSliceData(
            label: 'Dinheiro',
            amount: report.cashAmount,
            color: Colors.green,
            icon: Icons.attach_money,
          ),
        if (report.cardTotalAmount > 0)
          _PieSliceData(
            label: 'Cartão',
            amount: report.cardTotalAmount,
            color: Colors.teal,
            icon: Icons.credit_card,
          ),
        if (report.fiadoAmount > 0)
          _PieSliceData(
            label: 'Fiados',
            amount: report.fiadoAmount,
            color: Colors.pink,
            icon: Icons.pending_actions,
          ),
        if (report.pixAmount > 0)
          _PieSliceData(
            label: 'PIX',
            amount: report.pixAmount,
            color: Colors.deepPurpleAccent,
            icon: Icons.qr_code,
          ),
      ];
    } else {
      slices = [
        if (report.grossProfit > 0)
          _PieSliceData(
            label: 'Lucro Líquido',
            amount: report.grossProfit,
            color: AppColors.success,
            icon: Icons.trending_up,
          ),
        if (report.totalCost > 0)
          _PieSliceData(
            label: 'Custo de Produtos',
            amount: report.totalCost,
            color: Colors.brown,
            icon: Icons.inventory_2_outlined,
          ),
      ];
    }

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
          // Header: Título e Seletor do Modo do Gráfico
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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
                    '${widget.periodName} • ${report.salesCount} vendas',
                    style: context.textTheme.labelSmall?.copyWith(
                      color: context.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
              // Segmented Button / Tabs para alternar visualização
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: context.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(AppSpacing.radius24),
                  ),
                  padding: const EdgeInsets.all(2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: _PieViewMode.values.map((m) {
                      final isSelected = _mode == m;
                      return InkWell(
                        onTap: () => setState(() => _mode = m),
                        borderRadius: BorderRadius.circular(AppSpacing.radius24),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.space12,
                            vertical: AppSpacing.space8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected ? context.colorScheme.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(AppSpacing.radius24),
                          ),
                          child: Text(
                            m == _PieViewMode.payments ? 'Pagamentos' : 'Rentabilidade',
                            style: context.textTheme.labelSmall?.copyWith(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? Colors.white : context.colorScheme.onSurface.withValues(alpha: 0.8),
                              fontSize: 11,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),

          const Gap(AppSpacing.space16),

          if (!hasData) ...[
            SizedBox(
              height: 180,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.pie_chart_outline,
                      size: 44,
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
            // Gráfico de Pizza (Donut) e Legenda detalhada
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 380;

                final chartWidget = Center(
                  child: SizedBox(
                    width: 150,
                    height: 150,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: const Size(150, 150),
                          painter: _DonutChartPainter(
                            slices: slices,
                            total: totalSales,
                          ),
                        ),
                        // Conteúdo central do donut
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _mode == _PieViewMode.payments ? 'Total' : 'Margem',
                              style: context.textTheme.labelSmall?.copyWith(
                                color: context.colorScheme.onSurface.withValues(alpha: 0.6),
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              _mode == _PieViewMode.payments
                                  ? _currency.format(totalSales)
                                  : '${report.marginPercent.toStringAsFixed(1)}%',
                              style: context.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );

                final legendWidget = Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: slices.map((slice) {
                    final percent = totalSales > 0 ? (slice.amount / totalSales) * 100 : 0.0;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.space4),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: slice.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const Gap(AppSpacing.space8),
                          Expanded(
                            child: Text(
                              slice.label,
                              style: context.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            _currency.format(slice.amount),
                            style: context.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Gap(AppSpacing.space8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: slice.color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(AppSpacing.radius8),
                            ),
                            child: Text(
                              '${percent.toStringAsFixed(0)}%',
                              style: context.textTheme.labelSmall?.copyWith(
                                color: slice.color,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );

                if (isWide) {
                  return Row(
                    children: [
                      chartWidget,
                      const Gap(AppSpacing.space16),
                      Expanded(child: legendWidget),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      chartWidget,
                      const Gap(AppSpacing.space16),
                      legendWidget,
                    ],
                  );
                }
              },
            ),

            const Gap(AppSpacing.space16),

            // Rodapé com resumo complementar
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.space12,
                vertical: AppSpacing.space12,
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
                      Icon(
                        Icons.trending_up,
                        size: 16,
                        color: AppColors.success,
                      ),
                      const Gap(AppSpacing.space8),
                      Text(
                        'Lucro: ${_currency.format(report.grossProfit)}',
                        style: context.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 16,
                        color: Colors.brown,
                      ),
                      const Gap(AppSpacing.space8),
                      Text(
                        'Custo: ${_currency.format(report.totalCost)}',
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

class _PieSliceData {
  final String label;
  final double amount;
  final Color color;
  final IconData icon;

  const _PieSliceData({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
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
    const strokeWidth = 22.0;

    if (total <= 0 || slices.isEmpty) {
      final emptyPaint = Paint()
        ..color = Colors.grey.withValues(alpha: 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;
      canvas.drawCircle(center, radius - strokeWidth / 2, emptyPaint);
      return;
    }

    double startAngle = -math.pi / 2; // Inicia às 12 horas
    final rect = Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);

    for (final slice in slices) {
      final sweepAngle = (slice.amount / total) * 2 * math.pi;

      final paint = Paint()
        ..color = slice.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      // Se houver mais de uma fatia, aplica um pequeno espaçamento angular
      final adjustedSweep = slices.length > 1 ? math.max(sweepAngle - 0.05, 0.01) : sweepAngle;
      final adjustedStart = slices.length > 1 ? startAngle + 0.025 : startAngle;

      canvas.drawArc(rect, adjustedStart, adjustedSweep, false, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.total != total || oldDelegate.slices != slices;
  }
}
