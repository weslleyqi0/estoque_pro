import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/features/categories/presentation/viewmodels/categories_viewmodel.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_category_entity.dart';
import 'package:estoque_pro/app/features/categories/presentation/widgets/category_selection_item.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:estoque_pro/app/core/router/app_routes.dart';

class CategoriesBottomSheet extends StatefulWidget {
  final CategoriesViewModel categoriesVM;
  final List<ProductCategoryEntity> initialSelectedCategories;
  final void Function(List<ProductCategoryEntity> newCategories) onCategoriesChanged;

  const CategoriesBottomSheet({
    super.key,
    required this.categoriesVM,
    required this.initialSelectedCategories,
    required this.onCategoriesChanged,
  });

  static Future<void> show({
    required BuildContext context,
    required CategoriesViewModel categoriesVM,
    required List<ProductCategoryEntity> initialSelectedCategories,
    required void Function(List<ProductCategoryEntity> newCategories) onCategoriesChanged,
  }) {
    return AppBottomSheet.show(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return CategoriesBottomSheet(
          categoriesVM: categoriesVM,
          initialSelectedCategories: initialSelectedCategories,
          onCategoriesChanged: onCategoriesChanged,
        );
      },
    );
  }

  @override
  State<CategoriesBottomSheet> createState() => _CategoriesBottomSheetState();
}

class _CategoriesBottomSheetState extends State<CategoriesBottomSheet> {
  late final ValueNotifier<List<ProductCategoryEntity>> _selectedCategories;

  @override
  void initState() {
    super.initState();
    _selectedCategories = ValueNotifier(List.from(widget.initialSelectedCategories));
  }

  @override
  void dispose() {
    _selectedCategories.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.5,
      maxChildSize: 0.94,
      builder: (context, scrollController) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(top: AppSpacing.space16, bottom: AppSpacing.space16),
                    decoration: BoxDecoration(
                      color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16, vertical: AppSpacing.space8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Categorias',
                        style: context.textTheme.titleMedium,
                      ),
                      TextButton.icon(
                        onPressed: () => context.push(AppRoutes.categoryForm),
                        icon: const Icon(AppIcons.add, size: AppSpacing.icon24, weight: 600),
                        label: Text(
                          'Nova',
                          style: context.textTheme.titleSmall?.copyWith(color: context.colorScheme.primary),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListenableBuilder(
                    listenable: widget.categoriesVM,
                    builder: (context, _) {
                      if (widget.categoriesVM.state == CategoriesLoadState.loading) {
                        return const Padding(
                          padding: EdgeInsets.all(AppSpacing.space24),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      if (widget.categoriesVM.categories.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(AppSpacing.space24),
                          child: Center(child: Text('Nenhuma categoria cadastrada.')),
                        );
                      }
                      return ListView.builder(
                        controller: scrollController,
                        itemCount: widget.categoriesVM.categories.length,
                        itemBuilder: (context, index) {
                          final cat = widget.categoriesVM.categories[index];
                          return ValueListenableBuilder<List<ProductCategoryEntity>>(
                            valueListenable: _selectedCategories,
                            builder: (context, selected, _) {
                              final isSelected = selected.any((e) => e.id == cat.id);
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
                                child: CategorySelectionItem(
                                  category: cat,
                                  isSelected: isSelected,
                                  onTap: () {
                                    final currentList = List<ProductCategoryEntity>.from(selected);
                                    if (!isSelected) {
                                      currentList.add(ProductCategoryEntity(id: cat.id, name: cat.name));
                                    } else {
                                      currentList.removeWhere((e) => e.id == cat.id);
                                    }
                                    _selectedCategories.value = currentList;
                                    widget.onCategoriesChanged(currentList);
                                  },
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
