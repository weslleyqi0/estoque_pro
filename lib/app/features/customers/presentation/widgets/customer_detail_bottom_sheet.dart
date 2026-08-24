import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/core/router/app_routes.dart';
import 'package:estoque_pro/app/core/utils/cpf_input_formatter.dart';
import 'package:estoque_pro/app/core/utils/phone_input_formatter.dart';
import 'package:estoque_pro/app/features/customers/domain/entities/customer_entity.dart';
import 'package:estoque_pro/app/features/customers/presentation/widgets/customer_info_tile.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class CustomerDetailBottomSheet extends StatelessWidget {
  final CustomerEntity customer;
  final bool canEdit;

  const CustomerDetailBottomSheet({
    super.key,
    required this.customer,
    this.canEdit = true,
  });

  static Future<void> show({
    required BuildContext context,
    required CustomerEntity customer,
    bool canEdit = true,
  }) {
    return AppBottomSheet.show(
      context: context,
      builder: (_) => CustomerDetailBottomSheet(
        customer: customer,
        canEdit: canEdit,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasCpf = customer.cpf != null && customer.cpf!.trim().isNotEmpty;
    final hasPhone = customer.phone != null && customer.phone!.trim().isNotEmpty;
    final hasAddress = customer.address != null && customer.address!.trim().isNotEmpty;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(
          left: AppSpacing.space16,
          right: AppSpacing.space16,
          top: AppSpacing.space16,
          bottom: AppSpacing.space24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Gap(AppSpacing.space12),

            // Header: Title & Actions (Close / Edit)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Detalhes do Cliente',
                  style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (canEdit)
                      IconButton(
                        icon: const Icon(AppIcons.edit, size: AppSpacing.icon24),
                        tooltip: 'Editar Cliente',
                        onPressed: () {
                          Navigator.pop(context);
                          context.push(AppRoutes.customerForm, extra: customer);
                        },
                      ),
                    CloseButton(
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(),
            const Gap(AppSpacing.space12),

            // Customer Name & Status Header Card
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.space12),
                  decoration: BoxDecoration(
                    color: customer.isActive
                        ? context.colorScheme.primary.withValues(alpha: 0.2)
                        : context.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppSpacing.radius12),
                  ),
                  child: Icon(
                    AppIcons.person,
                    size: AppSpacing.icon32,
                    color: customer.isActive ? context.colorScheme.primary : context.colorScheme.onSurfaceVariant,
                  ),
                ),
                const Gap(AppSpacing.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.name,
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      AppTag(
                        title: customer.isActive ? 'Ativo' : 'Inativo',
                        color: customer.isActive ? AppColors.success : AppColors.error,
                        icon: customer.isActive ? AppIcons.checkCircle : AppIcons.block,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Gap(AppSpacing.space8),

            // Details List
            CustomerInfoTile(
              icon: AppIcons.badge,
              label: 'CPF',
              value: hasCpf ? CpfInputFormatter.formatString(customer.cpf!) : 'Não informado',
              isMuted: !hasCpf,
            ),
            CustomerInfoTile(
              icon: AppIcons.phone,
              label: 'Telefone',
              value: hasPhone ? PhoneInputFormatter.formatString(customer.phone!) : 'Não informado',
              isMuted: !hasPhone,
            ),
            CustomerInfoTile(
              icon: AppIcons.homeWork,
              label: 'Endereço',
              value: hasAddress ? customer.address! : 'Não informado',
              isMuted: !hasAddress,
            ),
          ],
        ),
      ),
    );
  }
}
