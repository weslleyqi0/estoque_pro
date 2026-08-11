import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

enum AppInfoBannerType {
  info,
  warning,
  success,
  error,
}

class AppInfoBanner extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final AppInfoBannerType type;
  final Color? color;
  final VoidCallback? onTap;
  final Widget? trailing;

  const AppInfoBanner({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.type = AppInfoBannerType.info,
    this.color,
    this.onTap,
    this.trailing,
  });

  Color _resolveColor(BuildContext context) {
    if (color != null) return color!;
    switch (type) {
      case AppInfoBannerType.info:
        return AppColors.info;
      case AppInfoBannerType.warning:
        return AppColors.warning;
      case AppInfoBannerType.success:
        return AppColors.success;
      case AppInfoBannerType.error:
        return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor = _resolveColor(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radius24),
      child: Container(
        padding: .only(
          left: AppSpacing.space12,
          right: trailing == null ? AppSpacing.space12 : 0,
          top: AppSpacing.space8,
          bottom: AppSpacing.space8,
        ),
        decoration: BoxDecoration(
          color: effectiveColor.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(AppSpacing.radius16),
          border: Border.all(
            color: effectiveColor,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Container(
                padding: const EdgeInsets.all(AppSpacing.space12),
                decoration: BoxDecoration(
                  color: effectiveColor,
                  borderRadius: AppSpacing.borderRadius12,
                ),
                child: Icon(
                  icon,
                  color: AppColors.white,
                  size: AppSpacing.icon32,
                ),
              ),
              const Gap(AppSpacing.space8),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.colorScheme.onSurface,
                      height: 1.3,
                    ),
                  ),
                  if (subtitle != null) ...[
                    Text(
                      subtitle!,
                      style: context.textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null)
              trailing!
            else if (onTap != null)
              Icon(
                Icons.chevron_right_rounded,
                color: effectiveColor,
              ),
          ],
        ),
      ),
    );
  }
}
