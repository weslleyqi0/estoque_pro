import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';

/// Design System Input/TextField Component
class AppTextfield extends StatefulWidget {
  final String? label;
  final String? hint;
  final bool required;
  final bool filled;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final bool showPasswordToggle;
  final bool showCharacterCounter;
  final FocusNode? focusNode;

  const AppTextfield({
    super.key,
    this.label,
    this.hint,
    this.required = false,
    this.filled = false,
    this.helperText,
    this.errorText,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
    this.validator,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.showPasswordToggle = false,
    this.showCharacterCounter = false,
    this.focusNode,
  });

  @override
  State<AppTextfield> createState() => _AppTextfieldState();
}

class _AppTextfieldState extends State<AppTextfield> {
  late bool _obscureText;
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget? prefixIconWidget;
    if (widget.prefixIcon != null) {
      prefixIconWidget = Icon(
        widget.prefixIcon,
        size: AppSpacing.icon20,
        color: _isFocused ? context.colorScheme.primary : context.colorScheme.onSurface.withValues(alpha: 0.6),
      );
    }

    Widget? suffixIconWidget;
    if (widget.showPasswordToggle && widget.obscureText) {
      suffixIconWidget = IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          size: AppSpacing.icon20,
        ),
        onPressed: _togglePasswordVisibility,
        color: context.colorScheme.onSurface.withValues(alpha: 0.6),
      );
    } else if (widget.suffixIcon != null) {
      suffixIconWidget = widget.onSuffixIconPressed != null
          ? IconButton(
              icon: Icon(widget.suffixIcon, size: AppSpacing.icon20),
              onPressed: widget.onSuffixIconPressed,
              color: context.colorScheme.onSurface.withValues(alpha: 0.6),
            )
          : Icon(
              widget.suffixIcon,
              size: AppSpacing.icon20,
              color: context.colorScheme.onSurface.withValues(alpha: 0.6),
            );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label! + (widget.required ? ' *' : ''),
            style: context.textTheme.labelLarge?.copyWith(
              color: context.colorScheme.onSurface,
            ),
          ),
          const Gap(AppSpacing.space8),
        ],
        TextFormField(
          controller: widget.controller,
          initialValue: widget.initialValue,
          focusNode: _focusNode,
          onChanged: widget.onChanged,
          onEditingComplete: widget.onEditingComplete,
          onFieldSubmitted: widget.onSubmitted,
          validator: widget.validator,
          obscureText: _obscureText,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          maxLines: widget.obscureText ? 1 : widget.maxLines,
          minLines: widget.minLines,
          maxLength: widget.maxLength,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          inputFormatters: widget.inputFormatters,
          style: context.textTheme.bodyLarge,
          decoration: InputDecoration(
            filled: widget.filled,
            fillColor: context.colorScheme.onPrimaryContainer.withValues(alpha: 0.1),
            hintText: widget.hint,
            helperText: widget.helperText,
            errorText: widget.errorText,
            prefixIcon: prefixIconWidget,
            suffixIcon: suffixIconWidget,
            counterText: widget.showCharacterCounter ? null : '',
            border: OutlineInputBorder(
              borderRadius: AppSpacing.borderRadius12,
              borderSide: BorderSide(color: context.colorScheme.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppSpacing.borderRadius12,
              borderSide: BorderSide(
                color: widget.filled
                    ? context.colorScheme.onPrimaryContainer.withValues(alpha: 0.2)
                    : context.colorScheme.outline,
                width: widget.filled ? 1 : 2,
              ),
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

/// Multiline Text Input (TextArea)
class AppTextArea extends StatelessWidget {
  final String? label;
  final String? hint;
  final bool required;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final bool enabled;
  final bool readOnly;
  final int minLines;
  final int? maxLines;
  final int? maxLength;
  final bool showCharacterCounter;

  const AppTextArea({
    super.key,
    this.label,
    this.hint,
    this.required = false,
    this.helperText,
    this.errorText,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.readOnly = false,
    this.minLines = 3,
    this.maxLines = 6,
    this.maxLength,
    this.showCharacterCounter = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextfield(
      label: label,
      hint: hint,
      required: required,
      helperText: helperText,
      errorText: errorText,
      controller: controller,
      initialValue: initialValue,
      onChanged: onChanged,
      validator: validator,
      enabled: enabled,
      readOnly: readOnly,
      minLines: minLines,
      maxLines: maxLines,
      maxLength: maxLength,
      showCharacterCounter: showCharacterCounter,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
    );
  }
}
