import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class SettingsDivider extends StatelessWidget {
  const SettingsDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: AppSpacing.space48 + AppSpacing.space8,
      endIndent: AppSpacing.space16,
      color: context.colorScheme.onSurface.withValues(alpha: 0.08),
    );
  }
}
