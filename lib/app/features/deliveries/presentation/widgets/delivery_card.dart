import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/core/utils/currency_input_formatter.dart';
import 'package:estoque_pro/app/features/deliveries/domain/entities/delivery_entity.dart';
import 'package:estoque_pro/app/features/deliveries/domain/entities/delivery_status.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class DeliveryCard extends StatelessWidget {
  final DeliveryEntity delivery;
  final VoidCallback? onTap;
  final ValueChanged<DeliveryStatus>? onStatusChanged;

  const DeliveryCard({
    super.key,
    required this.delivery,
    this.onTap,
    this.onStatusChanged,
  });

  String _formatScheduledDate(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final targetDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final timeStr = DateFormat('HH:mm').format(dateTime);

    if (targetDate == today) {
      return 'Hoje às $timeStr';
    } else if (targetDate == tomorrow) {
      return 'Amanhã às $timeStr';
    } else {
      return '${DateFormat('dd/MM/yyyy', 'pt_BR').format(dateTime)} às $timeStr';
    }
  }

  Color _getStatusColor(DeliveryStatus status) {
    switch (status) {
      case DeliveryStatus.pending:
        return AppColors.warning;
      case DeliveryStatus.inProgress:
        return Colors.blue;
      case DeliveryStatus.completed:
        return Colors.green;
      case DeliveryStatus.delayed:
        return AppColors.error;
      case DeliveryStatus.cancelled:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveStatus = delivery.effectiveStatus;
    final statusColor = _getStatusColor(effectiveStatus);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radius16),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.space16),
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppSpacing.radius16),
          border: Border.all(
            color: context.colorScheme.outline,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Header: Sale Number & Status Tag ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Venda ${delivery.saleNumber}',
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                AppTag(
                  title: '● ${effectiveStatus.label}',
                  color: statusColor,
                ),
              ],
            ),

            const Gap(AppSpacing.space24),

            // --- Cliente & Endereço ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.space12),
                  decoration: BoxDecoration(
                    color: context.colorScheme.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    AppIcons.truck,
                    size: AppSpacing.icon24,
                    color: context.colorScheme.primary,
                  ),
                ),
                const Gap(AppSpacing.space8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        delivery.customerName,
                        style: context.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (delivery.customerPhone != null && delivery.customerPhone!.isNotEmpty) ...[
                        Text(
                          delivery.customerPhone!,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      CurrencyInputFormatter.formatCurrency(delivery.totalAmount),
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.colorScheme.primary,
                      ),
                    ),
                    Text(
                      '${delivery.totalItems} ${delivery.totalItems == 1 ? 'item' : 'itens'}',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const Gap(AppSpacing.space8),
            Container(
              padding: const EdgeInsets.all(AppSpacing.space20),
              decoration: BoxDecoration(
                color: context.colorScheme.outline.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(AppSpacing.radius12),
                border: Border.all(
                  color: context.colorScheme.outline,
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    AppIcons.homePin,
                    size: AppSpacing.icon20,
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                  const Gap(AppSpacing.space8),
                  Expanded(
                    child: Text(
                      delivery.customerAddress.isNotEmpty ? delivery.customerAddress : 'Endereço não informado',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- Agendamento ---
            const Gap(AppSpacing.space16),
            Row(
              children: [
                Icon(
                  delivery.isDelayed ? AppIcons.calendarClock : AppIcons.event,
                  size: AppSpacing.icon16,
                  color: delivery.isDelayed ? AppColors.error : context.colorScheme.onSurfaceVariant,
                ),
                const Gap(AppSpacing.space8),
                Expanded(
                  child: Text(
                    'Agendado: ${_formatScheduledDate(delivery.scheduledAt)}',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: delivery.isDelayed ? AppColors.error : context.colorScheme.onSurface,
                      fontWeight: delivery.isDelayed ? .bold : .normal,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
