import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class AppEmptyList extends StatelessWidget {
  final IconData icon;
  final String message;
  final EdgeInsetsGeometry? padding;
  final Color? iconColor;
  final double? iconSize;

  const AppEmptyList({
    super.key,
    required this.message,
    this.padding,
    required this.icon,
    this.iconColor,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const .symmetric(
          vertical: AppSpacing.space16,
          horizontal: AppSpacing.space48,
        ),
        child: Column(
          mainAxisAlignment: .center,
          crossAxisAlignment: .stretch,
          children: [
            Container(
              padding: padding ?? const .all(AppSpacing.space24),
              decoration: BoxDecoration(
                color: (iconColor ?? context.colorScheme.primary).withValues(
                  alpha: context.isDark ? 0.2 : 0.1,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (iconColor ?? context.colorScheme.primary).withValues(
                      alpha: context.isDark ? 0.2 : 0.1,
                    ),
                    blurRadius: 10,
                    spreadRadius: 8,
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: (iconColor ?? context.colorScheme.primary).withValues(
                  alpha: context.isDark ? 1.0 : 0.8,
                ),
                size: iconSize ?? AppSpacing.icon32,
              ),
            ),
            const Gap(AppSpacing.space12),
            Text(
              message,
              textAlign: .center,
              style: context.textTheme.titleMedium?.copyWith(
                color: context.colorScheme.onSurface.withValues(alpha: 0.8),
                fontWeight: AppTypography.regular,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
