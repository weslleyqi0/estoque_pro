import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/core/di/service_locator.dart';
import 'package:estoque_pro/app/core/router/app_routes.dart';
import 'package:estoque_pro/app/core/utils/cpf_input_formatter.dart';
import 'package:estoque_pro/app/core/utils/phone_input_formatter.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:estoque_pro/app/features/customers/domain/entities/customer_entity.dart';
import 'package:estoque_pro/app/features/customers/domain/entities/customer_summary_entity.dart';
import 'package:estoque_pro/app/features/customers/presentation/viewmodels/customer_debts_viewmodel.dart';
import 'package:estoque_pro/app/features/customers/presentation/widgets/customer_all_statements_bottom_sheet.dart';
import 'package:estoque_pro/app/features/customers/presentation/widgets/customer_debt_summary_card.dart';
import 'package:estoque_pro/app/features/customers/presentation/widgets/customer_info_tile.dart';
import 'package:estoque_pro/app/features/customers/presentation/widgets/customer_statement_list.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class CustomerDetailBottomSheet extends StatefulWidget {
  final CustomerEntity customer;
  final bool canEdit;
  final CustomerDebtsViewModel? debtsViewModel;
  final AuthViewModel? authViewModel;

  const CustomerDetailBottomSheet({
    super.key,
    required this.customer,
    this.canEdit = true,
    this.debtsViewModel,
    this.authViewModel,
  });

  static Future<void> show({
    required BuildContext context,
    required CustomerEntity customer,
    bool canEdit = true,
    CustomerDebtsViewModel? debtsViewModel,
    AuthViewModel? authViewModel,
  }) {
    return AppBottomSheet.show(
      context: context,
      isScrollControlled: true,
      builder: (_) => CustomerDetailBottomSheet(
        customer: customer,
        canEdit: canEdit,
        debtsViewModel: debtsViewModel,
        authViewModel: authViewModel,
      ),
    );
  }

  @override
  State<CustomerDetailBottomSheet> createState() => _CustomerDetailBottomSheetState();
}

class _CustomerDetailBottomSheetState extends State<CustomerDetailBottomSheet> {
  bool _isFullyExpanded = true;

  @override
  Widget build(BuildContext context) {
    final customer = widget.customer;
    final canEdit = widget.canEdit;
    final hasCpf = customer.cpf != null && customer.cpf!.trim().isNotEmpty;
    final hasPhone = customer.phone != null && customer.phone!.trim().isNotEmpty;
    final hasAddress = customer.address != null && customer.address!.trim().isNotEmpty;

    final debtsVM = widget.debtsViewModel ??
        (getIt.isRegistered<CustomerDebtsViewModel>() ? getIt<CustomerDebtsViewModel>() : null);
    final authVM = widget.authViewModel ??
        (getIt.isRegistered<AuthViewModel>() ? getIt<AuthViewModel>() : null);

    return NotificationListener<DraggableScrollableNotification>(
      onNotification: (notification) {
        final isFullyExpanded = notification.extent >= 0.99;
        if (_isFullyExpanded != isFullyExpanded) {
          setState(() {
            _isFullyExpanded = isFullyExpanded;
          });
        }
        return false;
      },
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 1.0,
        minChildSize: 0.5,
        maxChildSize: 1.0,
        builder: (context, scrollController) {
          Widget content(CustomerSummaryEntity summary, List<dynamic> statement) {
            return SafeArea(
              top: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Fixo no Topo
                  Padding(
                    padding: EdgeInsets.only(
                      left: AppSpacing.space16,
                      right: AppSpacing.space16,
                      top: _isFullyExpanded ? AppSpacing.appBarHeight : AppSpacing.space12,
                    ),
                    child: Column(
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
                              style: context.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
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
                        const Gap(AppSpacing.space8),
                        const Divider(),
                      ],
                    ),
                  ),

                  // Corpo com Scroll
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.only(
                        left: AppSpacing.space16,
                        right: AppSpacing.space16,
                        top: AppSpacing.space8,
                        bottom: AppSpacing.space24,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                                  color: customer.isActive
                                      ? context.colorScheme.primary
                                      : context.colorScheme.onSurfaceVariant,
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

                          if (debtsVM != null && authVM != null) ...[
                            const Gap(AppSpacing.space16),

                            // Resumo de Débitos & Ação de Abatimento
                            CustomerDebtSummaryCard(
                              customer: customer,
                              summary: summary,
                              debtsViewModel: debtsVM,
                              authViewModel: authVM,
                            ),

                            const Gap(AppSpacing.space20),

                            // Extrato das Últimas Movimentações
                            CustomerStatementList(
                              statementItems: debtsVM.getCustomerStatement(customer.id),
                              customerName: customer.name,
                              debtsViewModel: debtsVM,
                              maxItems: 3,
                              showViewAll: true,
                              onViewAll: () => CustomerAllStatementsBottomSheet.show(
                                context: context,
                                customer: customer,
                                debtsViewModel: debtsVM,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          if (debtsVM != null) {
            return ListenableBuilder(
              listenable: debtsVM,
              builder: (context, _) {
                final summary = debtsVM.getCustomerSummary(customer.id);
                final statement = debtsVM.getCustomerStatement(customer.id);
                return content(summary, statement);
              },
            );
          }

          return content(const CustomerSummaryEntity(customerId: ''), const []);
        },
      ),
    );
  }
}
