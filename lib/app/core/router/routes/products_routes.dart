import 'package:estoque_pro/app/core/di/service_locator.dart';
import 'package:estoque_pro/app/core/router/app_routes.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:estoque_pro/app/features/categories/presentation/viewmodels/categories_viewmodel.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_entity.dart';
import 'package:estoque_pro/app/features/products/presentation/pages/archived_products_page.dart';
import 'package:estoque_pro/app/features/products/presentation/pages/product_details_page.dart';
import 'package:estoque_pro/app/features/products/presentation/pages/product_form_page.dart';
import 'package:estoque_pro/app/features/products/presentation/pages/product_history_page.dart';
import 'package:estoque_pro/app/features/products/presentation/pages/products_page.dart';
import 'package:estoque_pro/app/features/products/presentation/pages/select_product_page.dart';
import 'package:estoque_pro/app/features/products/presentation/viewmodels/archived_products_viewmodel.dart';
import 'package:estoque_pro/app/features/products/presentation/viewmodels/product_history_viewmodel.dart';
import 'package:estoque_pro/app/features/products/presentation/viewmodels/products_form_viewmodel.dart';
import 'package:estoque_pro/app/features/products/presentation/viewmodels/products_viewmodel.dart';
import 'package:estoque_pro/app/features/suppliers/presentation/viewmodels/suppliers_viewmodel.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

List<GoRoute> productsRoutes() {
  return [
    GoRoute(
      path: AppRoutes.products,
      builder: (context, state) {
        final extra = state.extra;
        final initialSearchQuery = extra is String && extra != 'empty_stock' && extra != 'low_stock' ? extra : null;
        final initialShowOnlyLowStock = (extra is bool && extra) ||
            extra == 'low_stock' ||
            (extra is Map && extra['lowStock'] == true);
        final initialShowOnlyEmptyStock = extra == 'empty_stock' ||
            (extra is Map && extra['emptyStock'] == true);

        return ProductsPage(
          viewModelFactory: () => getIt<ProductsViewModel>(),
          initialSearchQuery: initialSearchQuery,
          initialShowOnlyLowStock: initialShowOnlyLowStock,
          initialShowOnlyEmptyStock: initialShowOnlyEmptyStock,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.productForm,
      builder: (context, state) {
        final product = state.extra as ProductEntity?;
        return ProductFormPage(
          product: product,
          viewModelFactory: () => getIt<ProductsFormViewModel>(),
          categoriesVMFactory: () => getIt<CategoriesViewModel>(),
          suppliersVMFactory: () => getIt<SuppliersViewModel>(),
          authViewModel: getIt<AuthViewModel>(),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.productDetails,
      builder: (context, state) {
        final product = state.extra as ProductEntity?;
        if (product != null) {
          return ProductDetailsPage(
            product: product,
            viewModelFactory: () => getIt<ProductsViewModel>(),
            formViewModelFactory: () => getIt<ProductsFormViewModel>(),
            authViewModel: getIt<AuthViewModel>(),
          );
        }
        return ProductsPage(viewModelFactory: () => getIt<ProductsViewModel>());
      },
    ),
    GoRoute(
      path: AppRoutes.productHistory,
      builder: (context, state) {
        final product = state.extra as ProductEntity;
        return ProductHistoryPage(
          product: product,
          viewModelFactory: () => getIt<ProductHistoryViewModel>(),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.productSelect,
      pageBuilder: (context, state) {
        final title = state.extra as String?;
        return CustomTransitionPage(
          key: state.pageKey,
          child: SelectProductPage(
            viewModelFactory: () => getIt<ProductsViewModel>(),
            title: title,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.easeOutCubic;
            final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );
      },
    ),
    GoRoute(
      path: AppRoutes.archivedProducts,
      builder: (context, state) => ArchivedProductsPage(
        viewModelFactory: () => getIt<ArchivedProductsViewModel>(),
        authViewModel: getIt<AuthViewModel>(),
      ),
    ),
  ];
}
