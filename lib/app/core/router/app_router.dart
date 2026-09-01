import 'package:estoque_pro/app/core/di/service_locator.dart';
import 'package:estoque_pro/app/core/router/app_routes.dart';
import 'package:estoque_pro/app/core/router/auth_redirect_policy.dart';
import 'package:estoque_pro/app/core/router/routes/auth_routes.dart';
import 'package:estoque_pro/app/core/router/routes/categories_routes.dart';
import 'package:estoque_pro/app/core/router/routes/customers_routes.dart';
import 'package:estoque_pro/app/core/router/routes/deliveries_routes.dart';
import 'package:estoque_pro/app/core/router/routes/home_routes.dart';
import 'package:estoque_pro/app/core/router/routes/products_routes.dart';
import 'package:estoque_pro/app/core/router/routes/sales_routes.dart';
import 'package:estoque_pro/app/core/router/routes/settings_routes.dart';
import 'package:estoque_pro/app/core/router/routes/suppliers_routes.dart';
import 'package:estoque_pro/app/core/router/routes/users_routes.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static const _authRedirectPolicy = AuthRedirectPolicy();

  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.home,
    refreshListenable: getIt<AuthViewModel>(),
    redirect: (context, state) => _authRedirectPolicy.resolveRedirect(
      context,
      state,
      getIt<AuthViewModel>(),
    ),
    routes: [
      ...authRoutes(),
      ...homeRoutes(),
      ...productsRoutes(),
      ...categoriesRoutes(),
      ...suppliersRoutes(),
      ...customersRoutes(),
      ...salesRoutes(),
      ...deliveriesRoutes(),
      ...usersRoutes(),
      ...settingsRoutes(),
    ],
  );
}
