import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/core/router/app_routes.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:estoque_pro/app/features/suppliers/presentation/viewmodels/suppliers_viewmodel.dart';
import 'package:estoque_pro/app/features/suppliers/presentation/widgets/suppliers_list_sliver.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_permission.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SuppliersPage extends StatefulWidget {
  final SuppliersViewModel Function() viewModelFactory;
  final AuthViewModel authViewModel;

  const SuppliersPage({
    super.key,
    required this.viewModelFactory,
    required this.authViewModel,
  });

  @override
  State<SuppliersPage> createState() => _SuppliersPageState();
}

class _SuppliersPageState extends State<SuppliersPage> {
  late final SuppliersViewModel viewModel;

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
    final canManageSuppliers =
        widget.authViewModel.currentUser?.hasPermission(UserPermission.manageSuppliers) ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fornecedores'),
      ),

      floatingActionButton: canManageSuppliers
          ? AppFloatingActionButton(
              tooltip: 'Adicionar novo fornecedor',
              icon: AppIcons.add,
              onPressed: () => context.push(AppRoutes.supplierForm),
            )
          : null,

      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          return CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              if (viewModel.suppliers.isNotEmpty)
                AppFloatingSearch(
                  hint: 'Pesquisar fornecedor...',
                  initialValue: viewModel.searchQuery,
                  onChanged: viewModel.setSearchQuery,
                ),
              SuppliersListSliver(
                viewModel: viewModel,
                canEdit: canManageSuppliers,
              ),
            ],
          );
        },
      ),
    );
  }
}
