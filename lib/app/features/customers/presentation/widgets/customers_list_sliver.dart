import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:estoque_pro/app/features/customers/presentation/viewmodels/customer_debts_viewmodel.dart';
import 'package:estoque_pro/app/features/customers/presentation/viewmodels/customers_viewmodel.dart';
import 'package:estoque_pro/app/features/customers/presentation/widgets/customer_item.dart';
import 'package:flutter/material.dart';

class CustomersListSliver extends StatelessWidget {
  final CustomersViewModel viewModel;
  final CustomerDebtsViewModel debtsViewModel;
  final AuthViewModel authViewModel;
  final bool canEdit;

  const CustomersListSliver({
    super.key,
    required this.viewModel,
    required this.debtsViewModel,
    required this.authViewModel,
    this.canEdit = true,
  });

  @override
  Widget build(BuildContext context) {
    if (viewModel.state == CustomersLoadState.loading) {
      return const SliverFillRemaining(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (viewModel.state == CustomersLoadState.failure) {
      return SliverFillRemaining(
        child: Center(
          child: Text('Erro ao carregar clientes: ${viewModel.error}'),
        ),
      );
    }

    final customers = viewModel.filteredCustomers;

    if (customers.isEmpty) {
      return SliverFillRemaining(
        child: AppEmptyList(
          message: viewModel.searchQuery.isEmpty
              ? 'Nenhum cliente cadastrado.'
              : 'Nenhum cliente encontrado para "${viewModel.searchQuery}".',
          icon: AppIcons.group,
          iconColor: Colors.pink,
          iconSize: AppSpacing.icon48,
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space16,
        vertical: AppSpacing.space8,
      ),
      sliver: SliverList.builder(
        itemCount: customers.length,
        itemBuilder: (context, index) {
          final customer = customers[index];
          final summary = debtsViewModel.getCustomerSummary(customer.id);

          return CustomerItem(
            customer: customer,
            summary: summary,
            debtsViewModel: debtsViewModel,
            authViewModel: authViewModel,
            canEdit: canEdit,
          );
        },
      ),
    );
  }
}
