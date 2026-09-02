import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/features/reports/domain/entities/report_card_type.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class ReportCardReorderTile extends StatelessWidget {
  final ReportCardType item;
  final int index;
  final bool isVisible;
  final VoidCallback onToggleVisibility;

  const ReportCardReorderTile({
    super.key,
    required this.item,
    required this.index,
    required this.isVisible,
    required this.onToggleVisibility,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isVisible ? 1.0 : 0.5,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.space8),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space12,
          vertical: AppSpacing.space8,
        ),
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppSpacing.radius12),
          border: Border.all(
            color: context.colorScheme.outlineVariant.withValues(alpha: isVisible ? 0.4 : 0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: isVisible ? 0.15 : 0.08),
                borderRadius: BorderRadius.circular(AppSpacing.radius8),
              ),
              child: Icon(
                item.icon,
                color: isVisible ? item.color : context.colorScheme.outline,
                size: AppSpacing.icon24,
              ),
            ),
            const Gap(AppSpacing.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          item.title,
                          style: context.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            decoration: isVisible ? null : TextDecoration.lineThrough,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!isVisible) ...[
                        const Gap(AppSpacing.space8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: context.colorScheme.outline.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(AppSpacing.radius4),
                          ),
                          child: Text(
                            'Oculto',
                            style: context.textTheme.labelSmall?.copyWith(
                              fontSize: 10,
                              color: context.colorScheme.outline,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    item.subTitle,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                isVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: isVisible ? context.colorScheme.primary : context.colorScheme.outline,
              ),
              tooltip: isVisible ? 'Ocultar card' : 'Mostrar card',
              onPressed: onToggleVisibility,
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
      ),
    );
  }
}
