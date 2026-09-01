import 'package:estoque_pro/app/core/di/modules/core_module.dart';
import 'package:estoque_pro/app/core/services/database_service.dart';
import 'package:estoque_pro/app/features/products/domain/usecases/count_products_use_case.dart';
import 'package:estoque_pro/app/features/suppliers/data/repositories/suppliers_repository_impl.dart';
import 'package:estoque_pro/app/features/suppliers/domain/entities/supplier_entity.dart';
import 'package:estoque_pro/app/features/suppliers/domain/repositories/suppliers_repository.dart';
import 'package:estoque_pro/app/features/suppliers/domain/usecases/delete_supplier_use_case.dart';
import 'package:estoque_pro/app/features/suppliers/domain/usecases/get_suppliers_use_case.dart';
import 'package:estoque_pro/app/features/suppliers/domain/usecases/save_supplier_use_case.dart';
import 'package:estoque_pro/app/features/suppliers/domain/usecases/update_supplier_use_case.dart';
import 'package:estoque_pro/app/features/suppliers/presentation/viewmodels/suppliers_form_viewmodel.dart';
import 'package:estoque_pro/app/features/suppliers/presentation/viewmodels/suppliers_viewmodel.dart';
import 'package:get_it/get_it.dart';

void setupSuppliersModule(GetIt getIt) {
  // Database Service
  registerDatabaseService<SupplierEntity>(getIt, 'suppliers');

  // Repositories
  getIt.registerLazySingleton<SuppliersRepository>(
    () => SuppliersRepositoryImpl(
      getIt<DatabaseService<SupplierEntity>>(),
    ),
  );

  // UseCases
  getIt.registerFactory<GetSuppliersUseCase>(
    () => GetSuppliersUseCase(getIt<SuppliersRepository>()),
  );
  getIt.registerFactory<SaveSupplierUseCase>(
    () => SaveSupplierUseCase(getIt<SuppliersRepository>()),
  );
  getIt.registerFactory<UpdateSupplierUseCase>(
    () => UpdateSupplierUseCase(getIt<SuppliersRepository>()),
  );
  getIt.registerFactory<DeleteSupplierUseCase>(
    () => DeleteSupplierUseCase(getIt<SuppliersRepository>()),
  );

  // ViewModels
  getIt.registerFactory<SuppliersViewModel>(
    () => SuppliersViewModel(
      getIt<GetSuppliersUseCase>(),
      getIt<CountProductsUseCase>(),
    ),
  );
  getIt.registerFactory<SuppliersFormViewmodel>(
    () => SuppliersFormViewmodel(
      getIt<SaveSupplierUseCase>(),
      getIt<UpdateSupplierUseCase>(),
      getIt<DeleteSupplierUseCase>(),
    ),
  );
}
