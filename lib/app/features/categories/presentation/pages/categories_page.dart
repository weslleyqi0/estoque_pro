import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/core/di/service_locator.dart';
import 'package:estoque_pro/app/core/router/app_routes.dart';
import 'package:estoque_pro/app/features/categories/presentation/viewmodels/categories_viewmodel.dart';
import 'package:estoque_pro/app/features/categories/presentation/widgets/categories_item.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({
    super.key,
  });

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final _viewModel = getIt<CategoriesViewModel>();

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
        title: const Text('Categorias'),
      ),

      floatingActionButton: AppFloatingActionButton(
        tooltip: 'Adicionar nova categoria',
        icon: Symbols.add_rounded,
        onPressed: () => context.push(AppRoutes.categoryForm),
      ),

      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          return CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              if (_viewModel.categories.isNotEmpty)
                AppFloatingSearch(
                  hint: 'Pesquisar categoria...',
                  onChanged: _viewModel.setSearchQuery,
                ),
              if (_viewModel.state == CategoriesLoadState.loading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_viewModel.state == CategoriesLoadState.failure)
                SliverFillRemaining(
                  child: Center(child: Text(_viewModel.error.toString())),
                )
              else if (_viewModel.categories.isEmpty)
                SliverFillRemaining(
                  child: AppEmptyList(
                    message: 'Nenhuma categoria cadastrada!\nClique no botão abaixo para cadastrar uma nova categoria.',
                    icon: Symbols.stacks_rounded,
                    iconColor: Colors.deepPurple,
                    iconSize: AppSpacing.icon48,
                  ),
                )
              else if (_viewModel.filteredCategories.isEmpty)
                const SliverFillRemaining(
                  child: AppEmptyList(
                    message: 'Nenhuma categoria encontrada para essa pesquisa.',
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
                        final category = _viewModel.filteredCategories[index];
                        return CategoriesItem(category: category);
                      },
                      childCount: _viewModel.filteredCategories.length,
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
