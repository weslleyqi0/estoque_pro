import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Design System Floating Action Button Component
class AppFloatingActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String tooltip;
  final IconData icon;
  final Color? backgroundColor;
  final Color? iconColor;
  final double iconSize;
  final double elevation;
  final EdgeInsetsGeometry padding;

  const AppFloatingActionButton({
    super.key,
    required this.onPressed,
    required this.tooltip,
    required this.icon,
    this.backgroundColor,
    this.iconColor,
    this.iconSize = AppSpacing.icon48,
    this.elevation = 12,
    this.padding = const EdgeInsets.all(AppSpacing.space16),
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radius24),
        ),
        color: backgroundColor ?? context.colorScheme.primary,
        elevation: elevation,
        child: InkWell(
          onTap: onPressed,
          borderRadius: AppSpacing.borderRadius24,
          child: Padding(
            padding: padding,
            child: Icon(
              icon,
              color: iconColor ?? AppColors.white,
              size: iconSize,
            ),
          ),
        ),
      ),
    );
  }
}
