import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/core/router/app_routes.dart';
import 'package:estoque_pro/app/features/categories/presentation/viewmodels/categories_viewmodel.dart';
import 'package:estoque_pro/app/features/categories/presentation/widgets/categories_list_sliver.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CategoriesPage extends StatefulWidget {
  final CategoriesViewModel viewModel;

  const CategoriesPage({
    super.key,
    required this.viewModel,
  });

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
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
        title: const Text('Categorias'),
      ),

      floatingActionButton: AppFloatingActionButton(
        tooltip: 'Adicionar nova categoria',
        icon: AppIcons.add,
        onPressed: () => context.push(AppRoutes.categoryForm),
      ),

      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          return CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              if (widget.viewModel.categories.isNotEmpty)
                AppFloatingSearch(
                  hint: 'Pesquisar categoria...',
                  initialValue: widget.viewModel.searchQuery,
                  onChanged: widget.viewModel.setSearchQuery,
                ),
              CategoriesListSliver(viewModel: widget.viewModel),
            ],
          );
        },
      ),
    );
  }
}
