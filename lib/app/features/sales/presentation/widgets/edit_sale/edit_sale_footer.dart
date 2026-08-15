import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/core/utils/currency_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class EditSaleFooter extends StatelessWidget {
  final double originalTotal;
  final double newTotal;
  final bool canCancel;
  final bool isSaving;
  final bool hasChanges;
  final VoidCallback onCancelSale;
  final VoidCallback onSaveEdit;

  const EditSaleFooter({
    super.key,
    required this.originalTotal,
    required this.newTotal,
    required this.canCancel,
    required this.isSaving,
    required this.hasChanges,
    required this.onCancelSale,
    required this.onSaveEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.space16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Original:',
                style: context.textTheme.bodyMedium,
              ),
              Text(
                CurrencyInputFormatter.formatCurrency(originalTotal),
                style: context.textTheme.bodyMedium,
              ),
            ],
          ),
          const Gap(4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Novo Total:',
                style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                CurrencyInputFormatter.formatCurrency(newTotal),
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colorScheme.primary,
                ),
              ),
            ],
          ),
          const Gap(AppSpacing.space16),
          Row(
            children: [
              if (canCancel) ...[
                Expanded(
                  child: AppButton.outlined(
                    onPressed: isSaving ? null : onCancelSale,
                    borderColor: context.colorScheme.error,
                    backgroundColor: context.colorScheme.error.withValues(alpha: 0.1),
                    label: 'Cancelar Venda',
                  ),
                ),
                const Gap(AppSpacing.space8),
              ],
              Expanded(
                child: AppButton(
                  onPressed: (hasChanges && !isSaving) ? onSaveEdit : null,
                  isLoading: isSaving,
                  label: 'Salvar Edição',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
