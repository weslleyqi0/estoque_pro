import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class AppSwitchTitle extends StatelessWidget {
  final bool value;
  final String title;
  final String? subtitle;
  final TextStyle? titleStyle;
  final void Function(bool)? onChanged;

  const AppSwitchTitle({
    super.key,
    required this.value,
    required this.title,
    this.subtitle,
    this.titleStyle,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: .spaceBetween,
      children: [
        Flexible(
          child: Column(
            crossAxisAlignment: .start,
            children: [
              Text(
                title,
                style: (titleStyle ?? context.textTheme.titleMedium)?.copyWith(
                  color: value == false ? context.colorScheme.onSurface.withValues(alpha: 0.6) : null,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: value == false ? context.colorScheme.onSurface.withValues(alpha: 0.4) : null,
                  ),
                  overflow: TextOverflow.clip,
                ),
            ],
          ),
        ),
        Gap(AppSpacing.space8),
        Switch(
          value: value,
          onChanged: onChanged ?? (_) {},
        ),
      ],
    );
  }
}
