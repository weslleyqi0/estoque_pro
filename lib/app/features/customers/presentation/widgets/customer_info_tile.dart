import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class CustomerInfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isMuted;

  const CustomerInfoTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.isMuted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16, vertical: AppSpacing.space8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: AppSpacing.icon20,
            color: context.colorScheme.primary,
          ),
          const Gap(AppSpacing.space8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
                const Gap(2),
                Text(
                  value,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: isMuted ? context.colorScheme.onSurfaceVariant : context.colorScheme.onSurface,
                    fontStyle: isMuted ? FontStyle.italic : FontStyle.normal,
                    fontWeight: isMuted ? FontWeight.normal : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
