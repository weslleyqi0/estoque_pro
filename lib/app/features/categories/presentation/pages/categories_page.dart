import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/core/router/app_routes.dart';
import 'package:estoque_pro/app/features/categories/presentation/viewmodels/categories_viewmodel.dart';
import 'package:estoque_pro/app/features/categories/presentation/widgets/categories_list_sliver.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CategoriesPage extends StatefulWidget {
  final CategoriesViewModel Function() viewModelFactory;

  const CategoriesPage({
    super.key,
    required this.viewModelFactory,
  });

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  late final CategoriesViewModel viewModel;

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
        listenable: viewModel,
        builder: (context, _) {
          return CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              if (viewModel.categories.isNotEmpty)
                AppFloatingSearch(
                  hint: 'Pesquisar categoria...',
                  initialValue: viewModel.searchQuery,
                  onChanged: viewModel.setSearchQuery,
                ),
              CategoriesListSliver(viewModel: viewModel),
            ],
          );
        },
      ),
    );
  }
}
