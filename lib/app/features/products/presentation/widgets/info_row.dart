import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? warningColor;

  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.warningColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        const Gap(AppSpacing.space16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: context.textTheme.titleSmall?.copyWith(color: warningColor),
          ),
        ),
      ],
    );
  }
}
