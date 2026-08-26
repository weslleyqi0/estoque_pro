import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/features/deliveries/domain/entities/delivery_status.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class DeliveryStatusBanner extends StatelessWidget {
  final DeliveryStatus status;
  final bool isDelayed;
  final DateTime? scheduledAt;
  final String? title;
  final String? subtitle;

  const DeliveryStatusBanner({
    super.key,
    required this.status,
    this.isDelayed = false,
    this.scheduledAt,
    this.title,
    this.subtitle,
  });

  Color _getColor(BuildContext context) {
    if (isDelayed || status == DeliveryStatus.delayed) {
      return AppColors.error;
    }
    switch (status) {
      case DeliveryStatus.pending:
        return AppColors.warning;
      case DeliveryStatus.inProgress:
        return context.colorScheme.primary;
      case DeliveryStatus.completed:
        return Colors.green;
      case DeliveryStatus.delayed:
        return AppColors.error;
      case DeliveryStatus.cancelled:
        return context.colorScheme.onSurfaceVariant;
    }
  }

  IconData _getIcon() {
    if (isDelayed || status == DeliveryStatus.delayed) {
      return AppIcons.warning;
    }
    switch (status) {
      case DeliveryStatus.pending:
        return AppIcons.schedule;
      case DeliveryStatus.inProgress:
        return AppIcons.truck;
      case DeliveryStatus.completed:
        return AppIcons.checkCircle;
      case DeliveryStatus.delayed:
        return AppIcons.warning;
      case DeliveryStatus.cancelled:
        return AppIcons.close;
    }
  }

  String _getTitle() {
    if (title != null) return title!;
    final effectiveStatus = (isDelayed || status == DeliveryStatus.delayed)
        ? DeliveryStatus.delayed
        : status;
    return 'Status: ${effectiveStatus.label}';
  }

  String _getSubtitle() {
    if (subtitle != null) return subtitle!;
    if (scheduledAt != null) {
      final formatted = DateFormat("dd/MM/yyyy 'às' HH:mm", 'pt_BR').format(scheduledAt!);
      return 'Agendado para $formatted';
    }
    switch (status) {
      case DeliveryStatus.pending:
        return 'Aguardando início do envio';
      case DeliveryStatus.inProgress:
        return 'Entrega a caminho do destinatário';
      case DeliveryStatus.completed:
        return 'Entrega concluída com sucesso';
      case DeliveryStatus.delayed:
        return 'Prazo previsto expirou';
      case DeliveryStatus.cancelled:
        return 'Entrega foi cancelada';
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getColor(context);
    final statusIcon = _getIcon();
    final effectiveTitle = _getTitle();
    final effectiveSubtitle = _getSubtitle();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.space12),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radius12),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.space8),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppSpacing.radius8),
            ),
            child: Icon(
              statusIcon,
              color: statusColor,
              size: AppSpacing.icon20,
            ),
          ),
          const Gap(AppSpacing.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  effectiveTitle,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
                const Gap(2),
                Text(
                  effectiveSubtitle,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
