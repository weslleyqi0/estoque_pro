import 'package:estoque_pro/app/core/di/service_locator.dart';
import 'package:estoque_pro/app/core/router/app_routes.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:estoque_pro/app/features/suppliers/domain/entities/supplier_entity.dart';
import 'package:estoque_pro/app/features/suppliers/presentation/pages/supplier_form_page.dart';
import 'package:estoque_pro/app/features/suppliers/presentation/pages/suppliers_page.dart';
import 'package:estoque_pro/app/features/suppliers/presentation/viewmodels/suppliers_form_viewmodel.dart';
import 'package:estoque_pro/app/features/suppliers/presentation/viewmodels/suppliers_viewmodel.dart';
import 'package:go_router/go_router.dart';

List<GoRoute> suppliersRoutes() {
  return [
    GoRoute(
      path: AppRoutes.suppliers,
      builder: (context, state) => SuppliersPage(
        viewModelFactory: () => getIt<SuppliersViewModel>(),
        authViewModel: getIt<AuthViewModel>(),
      ),
    ),
    GoRoute(
      path: AppRoutes.supplierForm,
      builder: (context, state) {
        final supplier = state.extra as SupplierEntity?;
        return SupplierFormPage(
          viewModelFactory: () => getIt<SuppliersFormViewmodel>(),
          supplier: supplier,
        );
      },
    ),
  ];
}
