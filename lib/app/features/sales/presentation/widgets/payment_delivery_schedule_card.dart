import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class PaymentDeliveryScheduleCard extends StatelessWidget {
  final DateTime scheduledDate;
  final VoidCallback onTap;
  final String label;

  const PaymentDeliveryScheduleCard({
    super.key,
    required this.scheduledDate,
    required this.onTap,
    this.label = 'Agendamento da Entrega',
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radius12),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space12,
          vertical: AppSpacing.space12,
        ),
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppSpacing.radius12),
          border: Border.all(
            color: context.colorScheme.outline,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.space8),
              decoration: BoxDecoration(
                color: context.colorScheme.primary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(AppSpacing.radius8),
              ),
              child: Icon(
                AppIcons.calendarMonth,
                color: context.colorScheme.primary,
                size: AppSpacing.icon20,
              ),
            ),
            const Gap(AppSpacing.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: context.textTheme.bodySmall,
                  ),
                  const Gap(2),
                  Text(
                    DateFormat("dd/MM/yyyy 'às' HH:mm", 'pt_BR').format(scheduledDate),
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              AppIcons.calendarClock,
              color: context.colorScheme.primary,
              size: AppSpacing.icon20,
            ),
          ],
        ),
      ),
    );
  }
}
