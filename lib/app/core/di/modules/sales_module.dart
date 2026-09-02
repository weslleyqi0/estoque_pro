import 'package:estoque_pro/app/core/di/modules/core_module.dart';
import 'package:estoque_pro/app/core/services/database_service.dart';
import 'package:estoque_pro/app/features/deliveries/domain/repositories/deliveries_repository.dart';
import 'package:estoque_pro/app/features/deliveries/domain/usecases/get_deliveries_use_case.dart';
import 'package:estoque_pro/app/features/products/domain/repositories/products_repository.dart';
import 'package:estoque_pro/app/features/products/domain/usecases/get_products_use_case.dart';
import 'package:estoque_pro/app/features/sales/data/repositories/sales_repository_impl.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/repositories/sales_repository.dart';
import 'package:estoque_pro/app/features/sales/domain/usecases/cancel_completed_sale_use_case.dart';
import 'package:estoque_pro/app/features/sales/domain/usecases/delete_sale_use_case.dart';
import 'package:estoque_pro/app/features/sales/domain/usecases/edit_sale_use_case.dart';
import 'package:estoque_pro/app/features/sales/domain/usecases/finalize_sale_use_case.dart';
import 'package:estoque_pro/app/features/sales/domain/usecases/get_sales_use_case.dart';
import 'package:estoque_pro/app/features/sales/domain/usecases/save_draft_sale_use_case.dart';
import 'package:estoque_pro/app/features/sales/domain/usecases/save_sale_use_case.dart';
import 'package:estoque_pro/app/features/sales/presentation/viewmodels/cart_viewmodel.dart';
import 'package:estoque_pro/app/features/sales/presentation/viewmodels/edit_sale_viewmodel.dart';
import 'package:estoque_pro/app/features/sales/presentation/viewmodels/sales_viewmodel.dart';
import 'package:get_it/get_it.dart';

void setupSalesModule(GetIt getIt) {
  // Database Service
  registerDatabaseService<SaleEntity>(getIt, 'sales');

  // Repositories
  getIt.registerLazySingleton<SalesRepository>(
    () => SalesRepositoryImpl(
      getIt<DatabaseService<SaleEntity>>(),
    ),
  );

  // UseCases
  getIt.registerFactory<SaveSaleUseCase>(
    () => SaveSaleUseCase(
      getIt<SalesRepository>(),
      getIt<ProductsRepository>(),
    ),
  );
  getIt.registerFactory<FinalizeSaleUseCase>(
    () => FinalizeSaleUseCase(
      getIt<SaveSaleUseCase>(),
    ),
  );
  getIt.registerFactory<SaveDraftSaleUseCase>(
    () => SaveDraftSaleUseCase(getIt<SaveSaleUseCase>()),
  );
  getIt.registerFactory<EditSaleUseCase>(
    () => EditSaleUseCase(
      getIt<SalesRepository>(),
      getIt<ProductsRepository>(),
    ),
  );
  getIt.registerFactory<CancelCompletedSaleUseCase>(
    () => CancelCompletedSaleUseCase(
      getIt<SalesRepository>(),
      getIt<DeliveriesRepository>(),
    ),
  );
  getIt.registerFactory<GetSalesUseCase>(
    () => GetSalesUseCase(getIt<SalesRepository>()),
  );
  getIt.registerFactory<DeleteSaleUseCase>(
    () => DeleteSaleUseCase(
      getIt<SalesRepository>(),
      getIt<DeliveriesRepository>(),
    ),
  );

  // ViewModels
  getIt.registerFactory<SalesViewModel>(
    () => SalesViewModel(
      getIt<GetSalesUseCase>(),
      getIt<DeleteSaleUseCase>(),
      getIt<GetDeliveriesUseCase>(),
    ),
  );
  getIt.registerFactory<CartViewModel>(
    () => CartViewModel(
      getIt<FinalizeSaleUseCase>(),
      getIt<SaveDraftSaleUseCase>(),
    ),
  );
  getIt.registerFactory<EditSaleViewModel>(
    () => EditSaleViewModel(
      getIt<EditSaleUseCase>(),
      getIt<CancelCompletedSaleUseCase>(),
      getIt<GetProductsUseCase>(),
    ),
  );
}
