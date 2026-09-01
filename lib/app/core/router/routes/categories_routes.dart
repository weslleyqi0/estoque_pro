import 'package:estoque_pro/app/core/di/service_locator.dart';
import 'package:estoque_pro/app/core/router/app_routes.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:estoque_pro/app/features/categories/domain/entities/category_entity.dart';
import 'package:estoque_pro/app/features/categories/presentation/pages/categories_page.dart';
import 'package:estoque_pro/app/features/categories/presentation/pages/category_form_page.dart';
import 'package:estoque_pro/app/features/categories/presentation/viewmodels/categories_form_viewmodel.dart';
import 'package:estoque_pro/app/features/categories/presentation/viewmodels/categories_viewmodel.dart';
import 'package:go_router/go_router.dart';

List<GoRoute> categoriesRoutes() {
  return [
    GoRoute(
      path: AppRoutes.categories,
      builder: (context, state) => CategoriesPage(
        viewModelFactory: () => getIt<CategoriesViewModel>(),
        authViewModel: getIt<AuthViewModel>(),
      ),
    ),
    GoRoute(
      path: AppRoutes.categoryForm,
      builder: (context, state) {
        final category = state.extra as CategoryEntity?;
        return CategoryFormPage(
          viewModelFactory: () => getIt<CategoriesFormViewmodel>(),
          category: category,
        );
      },
    ),
  ];
}
