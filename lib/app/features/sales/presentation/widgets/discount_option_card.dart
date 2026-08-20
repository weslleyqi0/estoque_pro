import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class DiscountOptionCard extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const DiscountOptionCard({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = context.colorScheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: .circular(AppSpacing.radius12),
      child: Container(
        width: 68,
        height: 68,
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withValues(alpha: 0.2) : context.colorScheme.outline.withValues(alpha: 0.5),
          borderRadius: .circular(AppSpacing.radius16),
          border: .all(
            color: isSelected ? primaryColor : context.colorScheme.outline,
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: context.textTheme.titleMedium?.copyWith(
              color: isSelected ? primaryColor : context.colorScheme.onSurface,
              fontWeight: isSelected ? .bold : .w500,
            ),
          ),
        ),
      ),
    );
  }
}
