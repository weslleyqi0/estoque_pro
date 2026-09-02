import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/core/router/app_routes.dart';
import 'package:estoque_pro/app/features/deliveries/presentation/viewmodels/deliveries_viewmodel.dart';
import 'package:estoque_pro/app/features/reports/domain/entities/deliveries_report_entity.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class DeliveriesReportCard extends StatelessWidget {
  final DeliveriesReportEntity deliveriesReport;

  const DeliveriesReportCard({
    super.key,
    required this.deliveriesReport,
  });

  @override
  Widget build(BuildContext context) {
    final hasDelayed = deliveriesReport.delayedCount > 0;

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
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.space8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppSpacing.radius8),
                    ),
                    child: const Icon(
                      Icons.local_shipping_outlined,
                      color: Colors.orange,
                      size: AppSpacing.icon20,
                    ),
                  ),
                  const Gap(AppSpacing.space12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Entregas',
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${deliveriesReport.totalDeliveries} entregas no período',
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
                onPressed: () => context.push(
                  AppRoutes.deliveries,
                  extra: DeliveryFilterTab.all,
                ),
                tooltip: 'Ver entregas',
              ),
            ],
          ),

          const Gap(AppSpacing.space16),

          // Métricas de Entregas
          Row(
            children: [
              Expanded(
                child: _DeliveryStatusItem(
                  label: 'Pendentes',
                  count: deliveriesReport.pendingCount,
                  color: AppColors.warning,
                  onTap: () => context.push(
                    AppRoutes.deliveries,
                    extra: DeliveryFilterTab.pending,
                  ),
                ),
              ),
              const Gap(AppSpacing.space8),
              Expanded(
                child: _DeliveryStatusItem(
                  label: 'Atrasadas',
                  count: deliveriesReport.delayedCount,
                  color: hasDelayed ? AppColors.error : Colors.grey,
                  isAlert: hasDelayed,
                  onTap: () => context.push(
                    AppRoutes.deliveries,
                    extra: DeliveryFilterTab.delayed,
                  ),
                ),
              ),
              const Gap(AppSpacing.space8),
              Expanded(
                child: _DeliveryStatusItem(
                  label: 'Concluídas',
                  count: deliveriesReport.completedCount,
                  color: AppColors.success,
                  onTap: () => context.push(
                    AppRoutes.deliveries,
                    extra: DeliveryFilterTab.completed,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DeliveryStatusItem extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final bool isAlert;
  final VoidCallback? onTap;

  const _DeliveryStatusItem({
    required this.label,
    required this.count,
    required this.color,
    this.isAlert = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: isAlert ? 0.15 : 0.08),
      borderRadius: BorderRadius.circular(AppSpacing.radius12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radius12),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space8,
            vertical: AppSpacing.space12,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radius12),
            border: Border.all(
              color: color.withValues(alpha: isAlert ? 0.4 : 0.2),
            ),
          ),
          child: Column(
            children: [
              Text(
                '$count',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const Gap(AppSpacing.space4),
              Text(
                label,
                style: context.textTheme.labelSmall?.copyWith(
                  fontSize: 11,
                  color: context.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
