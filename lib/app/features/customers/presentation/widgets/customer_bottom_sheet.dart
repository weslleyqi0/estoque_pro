import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/core/router/app_routes.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:estoque_pro/app/features/customers/domain/entities/customer_entity.dart';
import 'package:estoque_pro/app/features/customers/presentation/viewmodels/customer_debts_viewmodel.dart';
import 'package:estoque_pro/app/features/customers/presentation/viewmodels/customers_viewmodel.dart';
import 'package:estoque_pro/app/features/customers/presentation/widgets/customer_item.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class CustomerBottomSheet extends StatefulWidget {
  final CustomersViewModel customersVM;
  final CustomerDebtsViewModel debtsViewModel;
  final AuthViewModel authViewModel;
  final void Function(CustomerEntity customer) onCustomerSelected;
  final bool canManageCustomers;

  const CustomerBottomSheet({
    super.key,
    required this.customersVM,
    required this.debtsViewModel,
    required this.authViewModel,
    required this.onCustomerSelected,
    this.canManageCustomers = true,
  });

  static Future<void> show({
    required BuildContext context,
    required CustomersViewModel customersVM,
    required CustomerDebtsViewModel debtsViewModel,
    required AuthViewModel authViewModel,
    required void Function(CustomerEntity customer) onCustomerSelected,
    bool canManageCustomers = true,
  }) {
    return AppBottomSheet.show(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return CustomerBottomSheet(
          customersVM: customersVM,
          debtsViewModel: debtsViewModel,
          authViewModel: authViewModel,
          onCustomerSelected: onCustomerSelected,
          canManageCustomers: canManageCustomers,
        );
      },
    );
  }

  @override
  State<CustomerBottomSheet> createState() => _CustomerBottomSheetState();
}

class _CustomerBottomSheetState extends State<CustomerBottomSheet> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.customersVM.listenAll();
    widget.customersVM.setSearchQuery('');
    widget.debtsViewModel.listenAll();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.65,
      maxChildSize: 0.94,
      minChildSize: 0.4,
      builder: (context, scrollController) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(
                      top: AppSpacing.space16,
                      bottom: AppSpacing.space16,
                    ),
                    decoration: BoxDecoration(
                      color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.space16,
                    vertical: AppSpacing.space8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Selecionar Cliente',
                        style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      if (widget.canManageCustomers)
                        IconButton(
                          icon: const Icon(AppIcons.add),
                          tooltip: 'Adicionar Cliente',
                          onPressed: () {
                            Navigator.pop(context);
                            context.push(AppRoutes.customerForm);
                          },
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.space16,
                    vertical: AppSpacing.space4,
                  ),
                  child: AppTextfield(
                    controller: _searchController,
                    hint: 'Buscar por nome, CPF ou telefone...',
                    prefixIcon: AppIcons.search,
                    onChanged: (val) {
                      widget.customersVM.setSearchQuery(val);
                    },
                  ),
                ),
                const Gap(AppSpacing.space8),
                Expanded(
                  child: ListenableBuilder(
                    listenable: Listenable.merge([widget.customersVM, widget.debtsViewModel]),
                    builder: (context, _) {
                      final activeList = widget.customersVM.activeCustomers;

                      if (activeList.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.all(AppSpacing.space24),
                          child: Center(
                            child: Text(
                              widget.customersVM.searchQuery.isEmpty
                                  ? 'Nenhum cliente cadastrado.'
                                  : 'Nenhum cliente encontrado para "${widget.customersVM.searchQuery}".',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        controller: scrollController,
                        itemCount: activeList.length,
                        itemBuilder: (context, index) {
                          final customer = activeList[index];
                          final summary = widget.debtsViewModel.getCustomerSummary(customer.id);
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
                            child: CustomerItem(
                              customer: customer,
                              summary: summary,
                              debtsViewModel: widget.debtsViewModel,
                              authViewModel: widget.authViewModel,
                              canEdit: false,
                              onTap: () {
                                widget.onCustomerSelected(customer);
                                Navigator.pop(context);
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
