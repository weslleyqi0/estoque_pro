import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/payment_method.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:material_symbols_icons/symbols.dart';

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
    PaymentMethod.dinheiro => Symbols.universal_currency_alt_rounded,
    PaymentMethod.pix => Symbols.qr_code_2_rounded,
    PaymentMethod.credito => Symbols.credit_card_rounded,
    PaymentMethod.debito => Symbols.credit_score_rounded,
    PaymentMethod.fiado => Symbols.receipt_long_rounded,
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
            if (method == PaymentMethod.pix)
              AppSvg(
                assetName: AppIcons.pixLogo,
                color: iconColor,
                width: AppSpacing.icon28,
                height: AppSpacing.icon28,
              )
            else
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
