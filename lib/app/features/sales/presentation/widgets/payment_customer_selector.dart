import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class PaymentCustomerSelector extends StatelessWidget {
  final String? customerName;
  final bool isFiado;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const PaymentCustomerSelector({
    super.key,
    required this.customerName,
    required this.isFiado,
    required this.onTap,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final hasCustomer = customerName != null && customerName!.trim().isNotEmpty;
    final showError = isFiado && !hasCustomer;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Cliente',
              style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              isFiado ? '(Obrigatório no fiado)' : '(Opcional)',
              style: context.textTheme.labelMedium?.copyWith(
                color: isFiado ? AppColors.error : context.colorScheme.onSurfaceVariant,
                fontWeight: isFiado ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
        const Gap(AppSpacing.space8),
        Container(
          decoration: BoxDecoration(
            color: context.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppSpacing.radius12),
            border: Border.all(
              color: showError ? AppColors.error : context.colorScheme.outline,
              width: 1.5,
            ),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppSpacing.radius12),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.space12,
                vertical: AppSpacing.space12,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.space8),
                    decoration: BoxDecoration(
                      color: hasCustomer
                          ? context.colorScheme.primary.withValues(alpha: 0.3)
                          : context.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(AppSpacing.radius8),
                    ),
                    child: Icon(
                      AppIcons.person,
                      size: AppSpacing.icon24,
                      color: hasCustomer ? context.colorScheme.primary : context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Gap(AppSpacing.space12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hasCustomer ? customerName! : 'Nenhum cliente selecionado',
                          style: context.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          hasCustomer
                              ? 'Toque para alterar'
                              : (isFiado
                                    ? 'Toque aqui para selecionar cliente'
                                    : 'Toque aqui para adicionar cliente à venda'),
                          style: context.textTheme.bodySmall?.copyWith(color: context.colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  if (hasCustomer && onClear != null)
                    IconButton(
                      icon: const Icon(AppIcons.close, size: AppSpacing.icon24),
                      tooltip: 'Remover cliente',
                      onPressed: onClear,
                    )
                  else
                    Icon(
                      AppIcons.chevronRight,
                      color: context.colorScheme.onSurfaceVariant,
                      size: AppSpacing.icon24,
                    ),
                ],
              ),
            ),
          ),
        ),
        if (showError)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(
              'Selecione um cliente para prosseguir com venda no fiado.',
              style: context.textTheme.bodySmall?.copyWith(color: AppColors.error),
            ),
          ),
      ],
    );
  }
}
