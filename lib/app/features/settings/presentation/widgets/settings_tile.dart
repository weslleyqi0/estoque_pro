import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const SettingsTile({
    super.key,
    required this.icon,
    this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tile = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space16,
        vertical: AppSpacing.space12,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.space8),
            decoration: BoxDecoration(
              color: (iconColor ?? context.colorScheme.primary).withValues(alpha: 0.12),
              borderRadius: AppSpacing.borderRadius8,
            ),
            child: Icon(
              icon,
              size: AppSpacing.icon20,
              color: iconColor ?? context.colorScheme.primary,
            ),
          ),
          const Gap(AppSpacing.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null) ...[
                  const Gap(AppSpacing.space4),
                  Text(
                    subtitle!,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const Gap(AppSpacing.space8),
            trailing!,
          ] else if (onTap != null) ...[
            const Gap(AppSpacing.space8),
            Icon(
              AppIcons.chevronRight,
              size: AppSpacing.icon20,
              color: context.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ],
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: AppSpacing.borderRadius16,
        child: tile,
      );
    }

    return tile;
  }
}
