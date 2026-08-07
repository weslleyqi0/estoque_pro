import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/features/categories/presentation/viewmodels/categories_viewmodel.dart';
import 'package:estoque_pro/app/features/categories/presentation/widgets/categories_item.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class CategoriesListSliver extends StatelessWidget {
  final CategoriesViewModel viewModel;

  const CategoriesListSliver({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    if (viewModel.state == CategoriesLoadState.loading) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (viewModel.state == CategoriesLoadState.failure) {
      return SliverFillRemaining(
        child: Center(child: Text(viewModel.error.toString())),
      );
    }

    if (viewModel.categories.isEmpty) {
      return const SliverFillRemaining(
        child: AppEmptyList(
          message: 'Nenhuma categoria cadastrada!\nClique no botão abaixo para cadastrar uma nova categoria.',
          icon: Symbols.stacks_rounded,
          iconColor: Colors.deepPurple,
          iconSize: AppSpacing.icon48,
        ),
      );
    }

    if (viewModel.filteredCategories.isEmpty) {
      return const SliverFillRemaining(
        child: AppEmptyList(
          message: 'Nenhuma categoria encontrada para essa pesquisa.',
          icon: Symbols.search_off_rounded,
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
            final category = viewModel.filteredCategories[index];
            return CategoriesItem(category: category);
          },
          childCount: viewModel.filteredCategories.length,
        ),
      ),
    );
  }
}
