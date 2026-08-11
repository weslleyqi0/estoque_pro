import 'package:estoque_pro/app/core/di/service_locator.dart';
import 'package:estoque_pro/app/core/router/app_routes.dart';
import 'package:estoque_pro/app/core/router/route_guard.dart';
import 'package:estoque_pro/app/features/auth/presentation/pages/biometric_page.dart';
import 'package:estoque_pro/app/features/auth/presentation/pages/inactive_page.dart';
import 'package:estoque_pro/app/features/auth/presentation/pages/login_page.dart';
import 'package:estoque_pro/app/features/auth/presentation/pages/unauthorized_page.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/biometric_viewmodel.dart';
import 'package:estoque_pro/app/features/categories/domain/entities/category_entity.dart';
import 'package:estoque_pro/app/features/categories/presentation/pages/categories_page.dart';
import 'package:estoque_pro/app/features/categories/presentation/pages/category_form_page.dart';
import 'package:estoque_pro/app/features/home/presentation/pages/home_page.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_entity.dart';
import 'package:estoque_pro/app/features/products/presentation/pages/product_details_page.dart';
import 'package:estoque_pro/app/features/products/presentation/pages/product_form_page.dart';
import 'package:estoque_pro/app/features/products/presentation/pages/product_history_page.dart';
import 'package:estoque_pro/app/features/products/presentation/pages/products_page.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_entity.dart';
import 'package:estoque_pro/app/features/sales/presentation/pages/new_sale_page.dart';
import 'package:estoque_pro/app/features/sales/presentation/pages/sales_page.dart';
import 'package:estoque_pro/app/features/suppliers/domain/entities/supplier_entity.dart';
import 'package:estoque_pro/app/features/suppliers/presentation/pages/supplier_form_page.dart';
import 'package:estoque_pro/app/features/suppliers/presentation/pages/suppliers_page.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_permission.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_role.dart';
import 'package:estoque_pro/app/features/users/presentation/pages/users_page.dart';
import 'package:estoque_pro/app/features/users/presentation/viewmodels/users_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static ProductEntity? _lastSelectedProduct;

  static final _routeGuard = RouteGuard(
    routePermissions: {
      AppRoutes.productHistory: UserPermission.viewHistory,
      AppRoutes.suppliers: UserPermission.manageSuppliers,
      AppRoutes.supplierForm: UserPermission.manageSuppliers,
      AppRoutes.categories: UserPermission.manageCategories,
      AppRoutes.categoryForm: UserPermission.manageCategories,
    },
  );

  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.home,
    refreshListenable: getIt<AuthViewModel>(),
    redirect: (context, state) {
      final authViewModel = getIt<AuthViewModel>();

      final isAuthenticated = authViewModel.isAuthenticated;
      final isBiometricAuth = authViewModel.isBiometricAuthenticated;
      final currentUser = authViewModel.currentUser;

      final path = state.uri.path;
      final isLoginPage = path == AppRoutes.login;
      final isBiometricPage = path == AppRoutes.biometric;
      final isInactivePage = path == AppRoutes.inactive;

      if (!isAuthenticated) {
        return isLoginPage ? null : AppRoutes.login;
      }

      if (currentUser != null && !currentUser.isActive) {
        return isInactivePage ? null : AppRoutes.inactive;
      }

      if (!isBiometricAuth) {
        return isBiometricPage ? null : AppRoutes.biometric;
      }

      if (isLoginPage || isBiometricPage || (isInactivePage && currentUser?.isActive == true)) {
        return AppRoutes.home;
      }

      if (path.startsWith(AppRoutes.users) && currentUser?.role == UserRole.seller) {
        return AppRoutes.unauthorized;
      }

      return _routeGuard.redirect(context, state, currentUser);
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => LoginPage(viewModel: getIt<AuthViewModel>()),
      ),
      GoRoute(
        path: AppRoutes.biometric,
        builder: (context, state) => BiometricPage(viewModel: getIt<BiometricViewModel>()),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: AppRoutes.users,
        builder: (context, state) => UsersPage(viewModel: getIt<UsersViewModel>()),
      ),
      GoRoute(
        path: AppRoutes.suppliers,
        builder: (context, state) => SuppliersPage(),
      ),
      GoRoute(
        path: AppRoutes.supplierForm,
        builder: (context, state) {
          final supplier = state.extra as SupplierEntity?;
          return SupplierFormPage(supplier: supplier);
        },
      ),
      GoRoute(
        path: AppRoutes.categories,
        builder: (context, state) => const CategoriesPage(),
      ),
      GoRoute(
        path: AppRoutes.categoryForm,
        builder: (context, state) {
          final category = state.extra as CategoryEntity?;
          return CategoryFormPage(category: category);
        },
      ),
      GoRoute(
        path: AppRoutes.products,
        builder: (context, state) {
          final initialSearchQuery = state.extra as String?;
          return ProductsPage(initialSearchQuery: initialSearchQuery);
        },
      ),
      GoRoute(
        path: AppRoutes.productForm,
        builder: (context, state) {
          final product = state.extra as ProductEntity?;
          return ProductFormPage(product: product);
        },
      ),
      GoRoute(
        path: AppRoutes.productDetails,
        builder: (context, state) {
          final product = (state.extra as ProductEntity?) ?? _lastSelectedProduct;
          if (product != null) {
            _lastSelectedProduct = product;
            return ProductDetailsPage(product: product);
          }
          return const ProductsPage();
        },
      ),
      GoRoute(
        path: AppRoutes.productHistory,
        builder: (context, state) {
          final product = state.extra as ProductEntity;
          return ProductHistoryPage(product: product);
        },
      ),
      GoRoute(
        path: AppRoutes.sales,
        builder: (context, state) => const SalesPage(),
      ),
      GoRoute(
        path: AppRoutes.newSale,
        builder: (context, state) {
          final sale = state.extra as SaleEntity?;
          return NewSalePage(initialSale: sale);
        },
      ),

      GoRoute(
        path: AppRoutes.inactive,
        builder: (context, state) => InactivePage(viewModel: getIt<AuthViewModel>()),
      ),
      GoRoute(
        path: AppRoutes.unauthorized,
        builder: (context, state) => const UnauthorizedPage(),
      ),
    ],
  );
}
