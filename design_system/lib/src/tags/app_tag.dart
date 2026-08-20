import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class AppTag extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Color? color;
  final VoidCallback? onTap;

  const AppTag({
    super.key,
    required this.title,
    this.icon,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tagWidget = Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.space4, horizontal: AppSpacing.radius8),
      decoration: BoxDecoration(
        color: (color ?? context.colorScheme.onSurface).withValues(alpha: 0.2),
        borderRadius: AppSpacing.borderRadius8,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: color,
              size: AppSpacing.icon16,
              weight: 600,
            ),
            const Gap(AppSpacing.space4),
          ],
          Text(
            title,
            style: context.textTheme.labelSmall?.copyWith(color: color),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: AppSpacing.borderRadius8,
        child: tagWidget,
      );
    }

    return tagWidget;
  }
}
