import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/features/reports/domain/entities/report_card_type.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class ReportCardReorderTile extends StatelessWidget {
  final ReportCardType item;
  final int index;

  const ReportCardReorderTile({
    super.key,
    required this.item,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.space8),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space12,
        vertical: AppSpacing.space8,
      ),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSpacing.radius12),
        border: Border.all(
          color: context.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppSpacing.radius8),
            ),
            child: Icon(
              item.icon,
              color: item.color,
              size: AppSpacing.icon24,
            ),
          ),
          const Gap(AppSpacing.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.title,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  item.subTitle,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          ReorderableDragStartListener(
            index: index,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.space8),
              child: Icon(
                AppIcons.dragHandle,
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
