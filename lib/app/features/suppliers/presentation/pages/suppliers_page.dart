import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/core/di/service_locator.dart';
import 'package:estoque_pro/app/core/router/app_routes.dart';
import 'package:estoque_pro/app/features/suppliers/presentation/viewmodels/suppliers_viewmodel.dart';
import 'package:estoque_pro/app/features/suppliers/presentation/widgets/suppliers_item.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

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
        centerTitle: true,
        title: const Text('Fornecedores'),
      ),

      floatingActionButton: FloatingActionButton.large(
        onPressed: () => context.push(AppRoutes.supplierForm),
        child: const Icon(
          Symbols.add_rounded,
          color: AppColors.white,
          size: AppSpacing.icon48,
          weight: 600,
        ),
      ),

      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          return CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              AppFloatingSearch(
                hint: 'Pesquisar fornecedor...',
                onChanged: _viewModel.setSearchQuery,
              ),
              if (_viewModel.state == SuppliersLoadState.loading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_viewModel.state == SuppliersLoadState.failure)
                SliverFillRemaining(
                  child: Center(child: Text(_viewModel.error.toString())),
                )
              else if (_viewModel.suppliers.isEmpty)
                SliverFillRemaining(
                  child: AppEmptyList(
                    message: 'Nenhum fornecedor cadastrado!\nClique no botão abaixo para cadastrar um novo fornecedor.',
                    icon: Symbols.local_shipping_rounded,
                    iconColor: Colors.cyan,
                    iconSize: AppSpacing.icon48,
                  ),
                )
              else if (_viewModel.filteredSuppliers.isEmpty)
                const SliverFillRemaining(
                  child: AppEmptyList(
                    message: 'Nenhum fornecedor encontrado para essa pesquisa.',
                    icon: Symbols.search_off_rounded,
                    iconColor: Colors.grey,
                    iconSize: AppSpacing.icon48,
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.only(
                    left: AppSpacing.space16,
                    right: AppSpacing.space16,
                    bottom: AppSpacing.space32,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final supplier = _viewModel.filteredSuppliers[index];
                        return SuppliersItem(supplier: supplier);
                      },
                      childCount: _viewModel.filteredSuppliers.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
