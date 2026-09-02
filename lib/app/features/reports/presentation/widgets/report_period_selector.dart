import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/features/reports/domain/entities/report_period.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class ReportPeriodSelector extends StatelessWidget {
  final ReportPeriod period;
  final ValueChanged<ReportPeriodType> onPeriodSelected;
  final void Function(DateTime start, DateTime end) onCustomRangeSelected;

  const ReportPeriodSelector({
    super.key,
    required this.period,
    required this.onPeriodSelected,
    required this.onCustomRangeSelected,
  });

  Future<void> _handleCustomTap(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(
        start: period.startDate,
        end: period.endDate,
      ),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Selecione o intervalo do relatório',
      cancelText: 'Cancelar',
      confirmText: 'Aplicar',
      locale: const Locale('pt', 'BR'),
    );

    if (picked != null) {
      onCustomRangeSelected(picked.start, picked.end);
    }
  }

  String _formatPeriodDates() {
    final dateFormat = DateFormat('dd/MM/yyyy');
    switch (period.type) {
      case ReportPeriodType.today:
        return 'Hoje (${dateFormat.format(period.startDate)}) vs Ontem (${dateFormat.format(period.previousStartDate)})';
      case ReportPeriodType.week:
        return 'Semana (${dateFormat.format(period.startDate)} a ${dateFormat.format(period.endDate)})';
      case ReportPeriodType.month:
        return DateFormat("MMMM 'de' yyyy", 'pt_BR').format(period.startDate);
      case ReportPeriodType.year:
        return 'Ano de ${period.startDate.year}';
      case ReportPeriodType.custom:
        return '${dateFormat.format(period.startDate)} até ${dateFormat.format(period.endDate)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Barra horizontal de opções
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ReportPeriodType.values.map((type) {
              final isSelected = period.type == type;
              return Padding(
                padding: const EdgeInsets.only(right: AppSpacing.space8),
                child: ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(type.label),
                      if (type == ReportPeriodType.custom && isSelected) ...[
                        const Gap(AppSpacing.space4),
                        const Icon(Icons.calendar_today, size: 12),
                      ],
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (_) {
                    if (type == ReportPeriodType.custom) {
                      _handleCustomTap(context);
                    } else {
                      onPeriodSelected(type);
                    }
                  },
                  selectedColor: context.colorScheme.primary,
                  labelStyle: context.textTheme.labelMedium?.copyWith(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.white : context.colorScheme.onSurface,
                  ),
                  backgroundColor: context.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                  showCheckmark: false,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radius24),
                    side: BorderSide(
                      color: isSelected
                          ? context.colorScheme.primary
                          : context.colorScheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        const Gap(AppSpacing.space8),

        // Subtítulo descritivo com as datas ativas
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space4),
          child: Row(
            children: [
              Icon(
                Icons.date_range_outlined,
                size: 14,
                color: context.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              const Gap(AppSpacing.space8),
              Expanded(
                child: Text(
                  _formatPeriodDates(),
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurface.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
