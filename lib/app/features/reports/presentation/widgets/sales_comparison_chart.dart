import 'dart:math' as math;

import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/features/reports/domain/entities/sales_chart_point.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class SalesComparisonChart extends StatefulWidget {
  final List<SalesChartPoint> points;
  final String currentLabel;
  final String previousLabel;
  final double currentTotal;
  final double previousTotal;

  const SalesComparisonChart({
    super.key,
    required this.points,
    required this.currentLabel,
    required this.previousLabel,
    required this.currentTotal,
    required this.previousTotal,
  });

  @override
  State<SalesComparisonChart> createState() => _SalesComparisonChartState();
}

class _SalesComparisonChartState extends State<SalesComparisonChart> {
  int? _selectedIndex;
  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  @override
  Widget build(BuildContext context) {
    final hasData = widget.points.any((p) => p.currentAmount > 0 || p.previousAmount > 0);
    final maxAmount = widget.points.fold<double>(
      0.0,
      (max, p) => math.max(max, math.max(p.currentAmount, p.previousAmount)),
    );

    final safeMax = maxAmount > 0 ? maxAmount * 1.15 : 100.0;

    // Diferença percentual
    final diffPercent = widget.previousTotal > 0
        ? ((widget.currentTotal - widget.previousTotal) / widget.previousTotal) * 100
        : (widget.currentTotal > 0 ? 100.0 : 0.0);
    final isPositive = diffPercent >= 0;

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
          // Header com Título e Legenda
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Comparativo de Vendas',
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Gap(AppSpacing.space4),
                    Row(
                      children: [
                        Text(
                          _currencyFormat.format(widget.currentTotal),
                          style: context.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.colorScheme.primary,
                          ),
                        ),
                        const Gap(AppSpacing.space8),
                        if (widget.previousTotal > 0 || widget.currentTotal > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: (isPositive ? AppColors.success : AppColors.error).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(AppSpacing.radius8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                                  size: 12,
                                  color: isPositive ? AppColors.success : AppColors.error,
                                ),
                                const Gap(2),
                                Text(
                                  '${diffPercent.abs().toStringAsFixed(1)}%',
                                  style: context.textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isPositive ? AppColors.success : AppColors.error,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              // Legenda
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _LegendItem(
                    color: context.colorScheme.primary,
                    label: widget.currentLabel,
                    isOutline: false,
                  ),
                  const Gap(AppSpacing.space4),
                  _LegendItem(
                    color: Colors.grey.shade400,
                    label: widget.previousLabel,
                    isOutline: true,
                  ),
                ],
              ),
            ],
          ),

          const Gap(AppSpacing.space16),

          // Painel informativo do item selecionado
          if (_selectedIndex != null && _selectedIndex! < widget.points.length) ...[
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.space12,
                vertical: AppSpacing.space8,
              ),
              decoration: BoxDecoration(
                color: context.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(AppSpacing.radius8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ponto: ${widget.points[_selectedIndex!].label}',
                    style: context.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        '${widget.currentLabel}: ',
                        style: context.textTheme.labelSmall?.copyWith(
                          color: context.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _currencyFormat.format(widget.points[_selectedIndex!].currentAmount),
                        style: context.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const Gap(AppSpacing.space12),
                      Text(
                        '${widget.previousLabel}: ',
                        style: context.textTheme.labelSmall?.copyWith(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _currencyFormat.format(widget.points[_selectedIndex!].previousAmount),
                        style: context.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Gap(AppSpacing.space12),
          ],

          // Área do Gráfico
          SizedBox(
            height: 180,
            child: !hasData
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bar_chart,
                          size: 40,
                          color: context.colorScheme.outline.withValues(alpha: 0.4),
                        ),
                        const Gap(AppSpacing.space8),
                        Text(
                          'Nenhuma venda registrada nos períodos comparados',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: List.generate(widget.points.length, (index) {
                          final point = widget.points[index];
                          final isSelected = _selectedIndex == index;

                          final curHeightRatio = (point.currentAmount / safeMax).clamp(0.0, 1.0);
                          final prevHeightRatio = (point.previousAmount / safeMax).clamp(0.0, 1.0);

                          final chartHeight = constraints.maxHeight - 24; // reserva 24px para labels

                          final curHeight = curHeightRatio * chartHeight;
                          final prevHeight = prevHeightRatio * chartHeight;

                          return Expanded(
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedIndex = isSelected ? null : index;
                                });
                              },
                              borderRadius: BorderRadius.circular(AppSpacing.radius8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 2),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? context.colorScheme.primary.withValues(alpha: 0.08)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(AppSpacing.radius8),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    // Barras comparativas emparelhadas
                                    SizedBox(
                                      height: chartHeight,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          // Barra do período anterior (Outline cinza)
                                          Flexible(
                                            child: Container(
                                              width: 10,
                                              height: math.max(prevHeight, 2.0),
                                              decoration: BoxDecoration(
                                                color: Colors.grey.withValues(alpha: 0.15),
                                                borderRadius: const BorderRadius.vertical(
                                                  top: Radius.circular(4),
                                                ),
                                                border: Border.all(
                                                  color: Colors.grey.shade400,
                                                  width: 1.2,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const Gap(3),
                                          // Barra do período atual (Primary preenchida)
                                          Flexible(
                                            child: Container(
                                              width: 12,
                                              height: math.max(curHeight, 2.0),
                                              decoration: BoxDecoration(
                                                color: isSelected
                                                    ? context.colorScheme.primary
                                                    : context.colorScheme.primary.withValues(alpha: 0.85),
                                                borderRadius: const BorderRadius.vertical(
                                                  top: Radius.circular(4),
                                                ),
                                                boxShadow: curHeight > 4
                                                    ? [
                                                        BoxShadow(
                                                          color: context.colorScheme.primary.withValues(alpha: 0.25),
                                                          blurRadius: 4,
                                                          offset: const Offset(0, 1),
                                                        ),
                                                      ]
                                                    : null,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Gap(AppSpacing.space8),
                                    // Label do eixo X
                                    Text(
                                      point.label,
                                      style: context.textTheme.labelSmall?.copyWith(
                                        fontSize: 10,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                        color: isSelected
                                            ? context.colorScheme.primary
                                            : context.colorScheme.onSurface.withValues(alpha: 0.7),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final bool isOutline;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.isOutline,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: isOutline ? color.withValues(alpha: 0.15) : color,
            borderRadius: BorderRadius.circular(2),
            border: isOutline ? Border.all(color: color, width: 1.2) : null,
          ),
        ),
        const Gap(6),
        Text(
          label,
          style: context.textTheme.labelSmall?.copyWith(
            color: context.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
