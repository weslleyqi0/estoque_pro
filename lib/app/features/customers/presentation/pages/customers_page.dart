import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/core/router/app_routes.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:estoque_pro/app/features/customers/presentation/viewmodels/customers_viewmodel.dart';
import 'package:estoque_pro/app/features/customers/presentation/widgets/customers_list_sliver.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_permission.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomersPage extends StatefulWidget {
  final CustomersViewModel Function() viewModelFactory;
  final AuthViewModel authViewModel;

  const CustomersPage({
    super.key,
    required this.viewModelFactory,
    required this.authViewModel,
  });

  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  late final CustomersViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = widget.viewModelFactory();
    viewModel.listenAll();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.setSearchQuery('');
    });
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canManageCustomers =
        widget.authViewModel.currentUser?.hasPermission(UserPermission.managerCustomer) ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
      ),
      floatingActionButton: canManageCustomers
          ? AppFloatingActionButton(
              tooltip: 'Adicionar novo cliente',
              icon: AppIcons.add,
              onPressed: () => context.push(AppRoutes.customerForm),
            )
          : null,
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          return CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              if (viewModel.customers.isNotEmpty)
                AppFloatingSearch(
                  hint: 'Pesquisar cliente...',
                  initialValue: viewModel.searchQuery,
                  onChanged: viewModel.setSearchQuery,
                ),
              CustomersListSliver(
                viewModel: viewModel,
                canEdit: canManageCustomers,
              ),
            ],
          );
        },
      ),
    );
  }
}
