import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/core/router/app_routes.dart';
import 'package:estoque_pro/app/features/suppliers/presentation/viewmodels/suppliers_viewmodel.dart';
import 'package:estoque_pro/app/features/suppliers/presentation/widgets/suppliers_list_sliver.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SuppliersPage extends StatefulWidget {
  final SuppliersViewModel viewModel;

  const SuppliersPage({
    super.key,
    required this.viewModel,
  });

  @override
  State<SuppliersPage> createState() => _SuppliersPageState();
}

class _SuppliersPageState extends State<SuppliersPage> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.listenAll();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.viewModel.setSearchQuery('');
    });
  }

  @override
  void dispose() {
    widget.viewModel.dispose();
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
        listenable: widget.viewModel,
        builder: (context, _) {
          return CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              if (widget.viewModel.suppliers.isNotEmpty)
                AppFloatingSearch(
                  hint: 'Pesquisar fornecedor...',
                  initialValue: widget.viewModel.searchQuery,
                  onChanged: widget.viewModel.setSearchQuery,
                ),
              SuppliersListSliver(viewModel: widget.viewModel),
            ],
          );
        },
      ),
    );
  }
}
