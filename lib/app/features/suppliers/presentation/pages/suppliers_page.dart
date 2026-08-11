import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/core/di/service_locator.dart';
import 'package:estoque_pro/app/core/router/app_routes.dart';
import 'package:estoque_pro/app/features/suppliers/presentation/viewmodels/suppliers_viewmodel.dart';
import 'package:estoque_pro/app/features/suppliers/presentation/widgets/suppliers_list_sliver.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SuppliersPage extends StatefulWidget {
  const SuppliersPage({
    super.key,
  });

  @override
  State<SuppliersPage> createState() => _SuppliersPageState();
}

class _SuppliersPageState extends State<SuppliersPage> {
  final _viewModel = getIt<SuppliersViewModel>();

  @override
  void initState() {
    super.initState();
    _viewModel.setSearchQuery('');
    _viewModel.listenAll();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fornecedores'),
      ),

      floatingActionButton: AppFloatingActionButton(
        tooltip: 'Adicionar novo fornecedor',
        icon: AppIcons.add,
        onPressed: () => context.push(AppRoutes.supplierForm),
      ),

      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          return CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              if (_viewModel.suppliers.isNotEmpty)
                AppFloatingSearch(
                  hint: 'Pesquisar fornecedor...',
                  initialValue: _viewModel.searchQuery,
                  onChanged: _viewModel.setSearchQuery,
                ),
              SuppliersListSliver(viewModel: _viewModel),
            ],
          );
        },
      ),
    );
  }
}
