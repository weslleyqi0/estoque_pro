import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Button size variants
enum AppIconButtonSize { small, medium, large }

/// Button style variants
enum AppButtonVariant { primary, secondary, outlined, text }

/// Design System Button Component
class AppButton extends StatelessWidget {
  final String? label;
  final Widget? child;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final IconData? suffixIcon;

  const AppButton({
    super.key,
    this.label,
    this.child,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.suffixIcon,
  }) : assert(
         label != null || child != null,
         'Either text or child must be provided',
       );

  const AppButton.primary({
    super.key,
    this.label,
    this.child,
    required this.onPressed,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.suffixIcon,
  }) : variant = AppButtonVariant.primary,
       assert(
         label != null || child != null,
         'Either text or child must be provided',
       );

  const AppButton.secondary({
    super.key,
    this.label,
    this.child,
    required this.onPressed,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.suffixIcon,
  }) : variant = AppButtonVariant.secondary,
       assert(
         label != null || child != null,
         'Either text or child must be provided',
       );

  const AppButton.outlined({
    super.key,
    this.label,
    this.child,
    required this.onPressed,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.suffixIcon,
  }) : variant = AppButtonVariant.outlined,
       assert(
         label != null || child != null,
         'Either text or child must be provided',
       );

  const AppButton.text({
    super.key,
    this.label,
    this.child,
    required this.onPressed,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.suffixIcon,
  }) : variant = AppButtonVariant.text,
       assert(
         label != null || child != null,
         'Either text or child must be provided',
       );

  Widget _buildContent(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        width: AppSpacing.icon24,
        height: AppSpacing.icon24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            variant == AppButtonVariant.primary ||
                    variant == AppButtonVariant.secondary
                ? Colors.white
                : Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    }

    final content = child ?? Text(label!, style: AppTypography.titleMedium);

    if (icon == null && suffixIcon == null) {
      return content;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: AppSpacing.icon24),
          const SizedBox(width: AppSpacing.space8),
        ],
        content,
        if (suffixIcon != null) ...[
          const SizedBox(width: AppSpacing.space8),
          Icon(suffixIcon, size: AppSpacing.icon24),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    //final colorScheme = Theme.of(context).colorScheme;

    Widget button = switch (variant) {
      AppButtonVariant.primary => ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: context.colorScheme.primary,
          foregroundColor: context.colorScheme.onPrimary,
          disabledBackgroundColor: context.colorScheme.onSurface.withValues(
            alpha: 0.2,
          ),
          disabledForegroundColor: context.colorScheme.onSurface.withValues(
            alpha: 0.4,
          ),
          minimumSize: const Size(0, AppSpacing.buttonHeightLg),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.buttonHeightLg,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadius12,
          ),
          elevation: 0,
        ),
        child: _buildContent(context),
      ),
      AppButtonVariant.secondary => ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: context.colorScheme.secondary,
          foregroundColor: context.colorScheme.onSecondary,
          disabledBackgroundColor: context.colorScheme.onSurface.withValues(
            alpha: 0.2,
          ),
          disabledForegroundColor: context.colorScheme.onSurface.withValues(
            alpha: 0.4,
          ),
          minimumSize: const Size(0, AppSpacing.buttonHeightLg),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space20),
          shape: const RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadius12,
          ),
          elevation: 0,
        ),
        child: _buildContent(context),
      ),
      AppButtonVariant.outlined => OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: context.colorScheme.primary,
          disabledForegroundColor: context.colorScheme.onSurface.withValues(
            alpha: 0.4,
          ),
          minimumSize: const Size(0, AppSpacing.buttonHeightLg),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space20),
          side: BorderSide(
            color: isLoading || onPressed == null
                ? context.colorScheme.onSurface.withValues(alpha: 0.2)
                : context.colorScheme.primary,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadius12,
          ),
        ),
        child: _buildContent(context),
      ),
      AppButtonVariant.text => TextButton(
        onPressed: isLoading ? null : onPressed,
        style: TextButton.styleFrom(
          foregroundColor: context.colorScheme.primary,
          disabledForegroundColor: context.colorScheme.onSurface.withValues(
            alpha: 0.38,
          ),
          minimumSize: const Size(0, AppSpacing.buttonHeightLg),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space20),
          shape: const RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadius12,
          ),
        ),
        child: _buildContent(context),
      ),
    };

    if (isFullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }

    return button;
  }
}

/// Icon Button Component
class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final AppIconButtonSize size;
  final Color? iconColor;
  final Color? backgroundColor;
  final String? tooltip;

  const AppIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = AppIconButtonSize.medium,
    this.iconColor,
    this.backgroundColor,
    this.tooltip,
  });

  double get _iconSize => switch (size) {
    AppIconButtonSize.small => AppSpacing.icon16,
    AppIconButtonSize.medium => AppSpacing.icon20,
    AppIconButtonSize.large => AppSpacing.icon24,
  };

  double get _buttonSize => switch (size) {
    AppIconButtonSize.small => AppSpacing.space32,
    AppIconButtonSize.medium => AppSpacing.space40,
    AppIconButtonSize.large => AppSpacing.space48,
  };

  @override
  Widget build(BuildContext context) {
    final button = IconButton(
      icon: Icon(icon, size: _iconSize),
      onPressed: onPressed,
      color: iconColor ?? context.colorScheme.primary,
      style: IconButton.styleFrom(
        backgroundColor: backgroundColor,
        minimumSize: Size(_buttonSize, _buttonSize),
        maximumSize: Size(_buttonSize, _buttonSize),
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: button);
    }

    return button;
  }
}
