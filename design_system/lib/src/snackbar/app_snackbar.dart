import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

enum AppSnackbarType { success, error, warning, info }

class AppSnackbar {
  static (Color, Color, IconData) _getSpecificsByType(AppSnackbarType type) {
    switch (type) {
      case AppSnackbarType.success:
        return (
          Color.lerp(AppColors.success, Colors.white, 0.5)!,
          Color.lerp(AppColors.success, Colors.black, 0.5)!,
          Symbols.check_circle_outline_rounded,
        );
      case AppSnackbarType.error:
        return (
          Color.lerp(AppColors.error, Colors.white, 0.5)!,
          Color.lerp(AppColors.error, Colors.black, 0.3)!,
          Symbols.error_circle_rounded,
        );
      case AppSnackbarType.warning:
        return (
          Color.lerp(AppColors.warning, Colors.white, 0.4)!,
          Color.lerp(AppColors.warning, Colors.black, 0.4)!,
          Symbols.warning_rounded,
        );
      case AppSnackbarType.info:
        return (
          Color.lerp(AppColors.info, Colors.white, 0.5)!,
          Color.lerp(AppColors.info, Colors.black, 0.4)!,
          Symbols.info_rounded,
        );
    }
  }

  static void _showSnackbar(BuildContext context, String text, AppSnackbarType type) {
    if (!context.mounted) {
      return;
    }
    final (backgroundColor, iconColor, icon) = _getSpecificsByType(type);
    final snackbar = SnackBar(
      showCloseIcon: true,
      closeIconColor: iconColor,
      content: Row(
        children: [
          Icon(
            icon,
            color: iconColor,
            size: AppSpacing.icon32,
          ),
          const Gap(AppSpacing.space8),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodyMedium.copyWith(color: iconColor),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      padding: .only(left: AppSpacing.space12, top: AppSpacing.space12, bottom: AppSpacing.space12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radius16)),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }

  static void success(BuildContext context, String text) {
    _showSnackbar(context, text, AppSnackbarType.success);
  }

  static void error(BuildContext context, String text) {
    _showSnackbar(context, text, AppSnackbarType.error);
  }

  static void warning(BuildContext context, String text) {
    _showSnackbar(context, text, AppSnackbarType.warning);
  }

  static void info(BuildContext context, String text) {
    _showSnackbar(context, text, AppSnackbarType.info);
  }
}
