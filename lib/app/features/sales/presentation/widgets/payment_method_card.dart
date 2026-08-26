import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/payment_method.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class PaymentMethodCard extends StatelessWidget {
  final PaymentMethod method;
  final bool isSelected;
  final VoidCallback onTap;

  const PaymentMethodCard({
    super.key,
    required this.method,
    required this.isSelected,
    required this.onTap,
  });

  IconData get _icon => switch (method) {
    PaymentMethod.dinheiro => AppIcons.currency,
    PaymentMethod.pix => AppIcons.pix,
    PaymentMethod.credito => AppIcons.creditCard,
    PaymentMethod.debito => AppIcons.creditScore,
    PaymentMethod.fiado => AppIcons.receiptLong,
  };

  @override
  Widget build(BuildContext context) {
    final primaryColor = context.colorScheme.primary;
    final iconColor = isSelected ? primaryColor : context.colorScheme.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      borderRadius: .circular(AppSpacing.radius16),
      child: Container(
        width: 120,
        padding: const .symmetric(
          vertical: AppSpacing.space12,
          horizontal: AppSpacing.space8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withValues(alpha: 0.2) : context.colorScheme.outline.withValues(alpha: 0.5),
          borderRadius: .circular(AppSpacing.radius16),
          border: .all(
            color: isSelected ? primaryColor : context.colorScheme.outline,
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Column(
          mainAxisAlignment: .center,
          mainAxisSize: .min,
          children: [
            Icon(_icon, color: iconColor, size: AppSpacing.icon28),
            const Gap(AppSpacing.space8),
            Text(
              method.label,
              textAlign: .center,
              style: context.textTheme.labelMedium?.copyWith(
                color: isSelected ? primaryColor : context.colorScheme.onSurface,
                fontWeight: isSelected ? .bold : .w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
