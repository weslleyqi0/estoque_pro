import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

enum AppSnackbarType { success, error, warning, info }

class AppSnackbar {
  static bool _isShowing = false;
  static String? _currentText;

  static (Color, Color, IconData) _getSpecificsByType(AppSnackbarType type) {
    switch (type) {
      case AppSnackbarType.success:
        return (
          Color.lerp(AppColors.success, Colors.white, 0.6)!,
          Color.lerp(AppColors.success, Colors.black, 0.2)!,
          AppIcons.checkCircleOutline,
        );
      case AppSnackbarType.error:
        return (
          Color.lerp(AppColors.error, Colors.white, 0.6)!,
          Color.lerp(AppColors.error, Colors.black, 0.1)!,
          AppIcons.errorCircle,
        );
      case AppSnackbarType.warning:
        return (
          Color.lerp(AppColors.warning, Colors.white, 0.6)!,
          Color.lerp(AppColors.warning, Colors.black, 0.1)!,
          AppIcons.warning,
        );
      case AppSnackbarType.info:
        return (
          Color.lerp(AppColors.info, Colors.white, 0.5)!,
          Color.lerp(AppColors.info, Colors.black, 0.1)!,
          AppIcons.info,
        );
    }
  }

  static void _showSnackbar(BuildContext context, String text, AppSnackbarType type) {
    if (!context.mounted) {
      return;
    }

    if (_isShowing && _currentText == text) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    if (_isShowing) {
      messenger.clearSnackBars();
    }

    _isShowing = true;
    _currentText = text;

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
              style: AppTypography.bodyMedium.copyWith(color: context.colorScheme.onSurface),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      padding: .only(left: AppSpacing.space12, top: AppSpacing.space12, bottom: AppSpacing.space12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radius16),
        side: BorderSide(color: iconColor, width: 1.5),
      ),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
    );

    try {
      final controller = messenger.showSnackBar(snackbar);
      controller.closed
          .then((_) {
            if (_currentText == text) {
              _isShowing = false;
              _currentText = null;
            }
          })
          .catchError((_) {
            if (_currentText == text) {
              _isShowing = false;
              _currentText = null;
            }
          });
    } catch (_) {
      _isShowing = false;
      _currentText = null;
    }
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
