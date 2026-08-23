import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/features/suppliers/presentation/viewmodels/suppliers_viewmodel.dart';
import 'package:estoque_pro/app/features/suppliers/presentation/widgets/suppliers_item.dart';
import 'package:flutter/material.dart';

class SuppliersListSliver extends StatelessWidget {
  final SuppliersViewModel viewModel;
  final bool canEdit;

  const SuppliersListSliver({
    super.key,
    required this.viewModel,
    this.canEdit = true,
  });

  @override
  Widget build(BuildContext context) {
    if (viewModel.state == SuppliersLoadState.loading) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (viewModel.state == SuppliersLoadState.failure) {
      return SliverFillRemaining(
        child: Center(child: Text(viewModel.error.toString())),
      );
    }

    if (viewModel.suppliers.isEmpty) {
      return const SliverFillRemaining(
        child: AppEmptyList(
          message: 'Nenhum fornecedor cadastrado!\nClique no botão abaixo para cadastrar um novo fornecedor.',
          icon: AppIcons.localShipping,
          iconColor: Colors.cyan,
          iconSize: AppSpacing.icon48,
        ),
      );
    }

    if (viewModel.filteredSuppliers.isEmpty) {
      return const SliverFillRemaining(
        child: AppEmptyList(
          message: 'Nenhum fornecedor encontrado para essa pesquisa.',
          icon: AppIcons.searchOff,
          iconColor: Colors.grey,
          iconSize: AppSpacing.icon48,
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.only(
        left: AppSpacing.space16,
        right: AppSpacing.space16,
        bottom: AppSpacing.space32,
      ),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final supplier = viewModel.filteredSuppliers[index];
            final productCount = viewModel.getProductCountForSupplier(supplier.id);
            return SuppliersItem(
              supplier: supplier,
              productCount: productCount,
              canEdit: canEdit,
            );
          },
          childCount: viewModel.filteredSuppliers.length,
        ),
      ),
    );
  }
}
