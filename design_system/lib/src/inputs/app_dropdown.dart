import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Design System Dropdown Component
class AppDropdown<T> extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final FormFieldValidator<T>? validator;
  final IconData? prefixIcon;
  final bool enabled;

  const AppDropdown({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
    this.prefixIcon,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget? prefixIconWidget;
    if (prefixIcon != null) {
      prefixIconWidget = Icon(
        prefixIcon,
        size: AppSpacing.icon20,
        color: context.colorScheme.onSurface.withValues(alpha: 0.6),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: context.textTheme.labelMedium?.copyWith(
              color: context.colorScheme.onSurface,
            ),
          ),
          const Gap(AppSpacing.space8),
        ],
        DropdownButtonFormField<T>(
          initialValue: value,
          items: items,
          onChanged: enabled ? onChanged : null,
          validator: validator,
          style: context.textTheme.bodyLarge?.copyWith(
            color: context.colorScheme.onSurface,
          ),
          borderRadius: AppSpacing.borderRadius12,
          icon: Icon(
            AppIcons.dropDown,
            color: context.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: context.colorScheme.onPrimaryContainer.withValues(
              alpha: 0.2,
            ),
            hintText: hint,
            helperText: helperText,
            errorText: errorText,
            prefixIcon: prefixIconWidget,
            border: OutlineInputBorder(
              borderRadius: AppSpacing.borderRadius12,
              borderSide: BorderSide(color: context.colorScheme.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppSpacing.borderRadius12,
              borderSide: BorderSide(color: context.colorScheme.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppSpacing.borderRadius12,
              borderSide: BorderSide(
                color: context.colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: AppSpacing.borderRadius12,
              borderSide: BorderSide(color: context.colorScheme.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: AppSpacing.borderRadius12,
              borderSide: BorderSide(
                color: context.colorScheme.error,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.space16,
              vertical: AppSpacing.space20,
            ),
            constraints: const BoxConstraints(
              minHeight: AppSpacing.inputHeightLg,
            ),
          ),
        ),
      ],
    );
  }
}
