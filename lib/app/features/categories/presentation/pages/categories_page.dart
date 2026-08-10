import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/core/di/service_locator.dart';
import 'package:estoque_pro/app/core/router/app_routes.dart';
import 'package:estoque_pro/app/features/categories/presentation/viewmodels/categories_viewmodel.dart';
import 'package:estoque_pro/app/features/categories/presentation/widgets/categories_list_sliver.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
        icon: AppIcons.add,
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
              CategoriesListSliver(viewModel: _viewModel),
            ],
          );
        },
      ),
    );
  }
}
