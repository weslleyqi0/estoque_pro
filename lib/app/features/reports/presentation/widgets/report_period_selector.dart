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
    final primaryColor = context.colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Barra horizontal de opções (padronizada com as outras tabs do sistema)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
          child: Row(
            children: ReportPeriodType.values.map((type) {
              final isSelected = period.type == type;
              return Padding(
                padding: const EdgeInsets.only(right: AppSpacing.space8),
                child: InkWell(
                  onTap: () {
                    if (type == ReportPeriodType.custom) {
                      _handleCustomTap(context);
                    } else {
                      onPeriodSelected(type);
                    }
                  },
                  borderRadius: BorderRadius.circular(AppSpacing.radius16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.space12,
                      horizontal: AppSpacing.space16,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? primaryColor : context.colorScheme.surface.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(AppSpacing.radius24),
                      border: Border.all(
                        color: isSelected ? primaryColor : context.colorScheme.onSurface.withValues(alpha: 0.2),
                        width: isSelected ? 2.0 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          type.label,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: isSelected ? AppColors.white : context.colorScheme.onSurface.withValues(alpha: 0.8),
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                        if (type == ReportPeriodType.custom && isSelected) ...[
                          const Gap(AppSpacing.space8),
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: AppColors.white,
                          ),
                        ],
                      ],
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
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
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
