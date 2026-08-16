import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_edit_reason.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class EditSaleReasonSelector extends StatelessWidget {
  final List<SaleEditReason> reasons;
  final SaleEditReason selectedReason;
  final ValueChanged<SaleEditReason> onReasonSelected;

  const EditSaleReasonSelector({
    super.key,
    required this.reasons,
    required this.selectedReason,
    required this.onReasonSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Motivo da Edição',
          style: context.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const Gap(AppSpacing.space8),
        Center(
          child: Wrap(
            spacing: AppSpacing.space8,
            runSpacing: AppSpacing.space8,
            children: reasons.map((reason) {
              final selected = selectedReason == reason;
              return EditSaleReasonCard(
                reason: reason,
                isSelected: selected,
                onTap: () => onReasonSelected(reason),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class EditSaleReasonCard extends StatelessWidget {
  final SaleEditReason reason;
  final bool isSelected;
  final VoidCallback onTap;

  const EditSaleReasonCard({
    super.key,
    required this.reason,
    required this.isSelected,
    required this.onTap,
  });

  IconData get _icon => switch (reason) {
    SaleEditReason.addition => Icons.add_circle_outline_rounded,
    SaleEditReason.returnItem => Icons.assignment_return_rounded,
    SaleEditReason.exchange => Icons.swap_horiz_rounded,
    SaleEditReason.correction => Icons.edit_note_rounded,
    SaleEditReason.removal => Icons.remove_circle_outline_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final primaryColor = context.colorScheme.primary;
    final iconColor = isSelected ? primaryColor : context.colorScheme.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radius16),
      child: Container(
        width: 120,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.space8, horizontal: AppSpacing.space8),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withValues(alpha: 0.2) : context.colorScheme.outline.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppSpacing.radius16),
          border: Border.all(
            color: isSelected ? primaryColor : context.colorScheme.outline,
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_icon, color: iconColor, size: AppSpacing.icon28),
            const Gap(AppSpacing.space4),
            Text(
              reason.label,
              textAlign: TextAlign.center,
              style: context.textTheme.labelMedium?.copyWith(
                color: isSelected ? primaryColor : context.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
