import 'package:estoque_pro/app/core/di/modules/core_module.dart';
import 'package:estoque_pro/app/core/services/database_service.dart';
import 'package:estoque_pro/app/features/products/data/repositories/products_repository_impl.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_entity.dart';
import 'package:estoque_pro/app/features/products/domain/repositories/products_repository.dart';
import 'package:estoque_pro/app/features/products/domain/usecases/adjust_stock_use_case.dart';
import 'package:estoque_pro/app/features/products/domain/usecases/archive_product_use_case.dart';
import 'package:estoque_pro/app/features/products/domain/usecases/count_products_use_case.dart';
import 'package:estoque_pro/app/features/products/domain/usecases/delete_product_permanently_use_case.dart';
import 'package:estoque_pro/app/features/products/domain/usecases/get_products_use_case.dart';
import 'package:estoque_pro/app/features/products/domain/usecases/save_product_use_case.dart';
import 'package:estoque_pro/app/features/products/domain/usecases/unarchive_product_use_case.dart';
import 'package:estoque_pro/app/features/products/domain/usecases/update_product_use_case.dart';
import 'package:estoque_pro/app/features/products/domain/usecases/watch_product_history_use_case.dart';
import 'package:estoque_pro/app/features/products/presentation/viewmodels/archived_products_viewmodel.dart';
import 'package:estoque_pro/app/features/products/presentation/viewmodels/product_history_viewmodel.dart';
import 'package:estoque_pro/app/features/products/presentation/viewmodels/products_form_viewmodel.dart';
import 'package:estoque_pro/app/features/products/presentation/viewmodels/products_viewmodel.dart';
import 'package:get_it/get_it.dart';

void setupProductsModule(GetIt getIt) {
  // Database Service
  registerDatabaseService<ProductEntity>(getIt, 'products');

  // Repositories
  getIt.registerLazySingleton<ProductsRepository>(
    () => ProductsRepositoryImpl(
      getIt<DatabaseService<ProductEntity>>(),
    ),
  );

  // UseCases
  getIt.registerFactory<CountProductsUseCase>(
    () => CountProductsUseCase(getIt<ProductsRepository>()),
  );
  getIt.registerFactory<GetProductsUseCase>(
    () => GetProductsUseCase(getIt<ProductsRepository>()),
  );
  getIt.registerFactory<SaveProductUseCase>(
    () => SaveProductUseCase(getIt<ProductsRepository>()),
  );
  getIt.registerFactory<UpdateProductUseCase>(
    () => UpdateProductUseCase(getIt<ProductsRepository>()),
  );
  getIt.registerFactory<ArchiveProductUseCase>(
    () => ArchiveProductUseCase(getIt<ProductsRepository>()),
  );
  getIt.registerFactory<UnarchiveProductUseCase>(
    () => UnarchiveProductUseCase(getIt<ProductsRepository>()),
  );
  getIt.registerFactory<DeleteProductPermanentlyUseCase>(
    () => DeleteProductPermanentlyUseCase(getIt<ProductsRepository>()),
  );
  getIt.registerFactory<AdjustStockUseCase>(
    () => AdjustStockUseCase(getIt<ProductsRepository>()),
  );
  getIt.registerFactory<WatchProductHistoryUseCase>(
    () => WatchProductHistoryUseCase(getIt<ProductsRepository>()),
  );

  // ViewModels
  getIt.registerFactory<ProductsViewModel>(
    () => ProductsViewModel(
      getIt<GetProductsUseCase>(),
      getIt<ArchiveProductUseCase>(),
      getIt<UnarchiveProductUseCase>(),
      getIt<DeleteProductPermanentlyUseCase>(),
      getIt<WatchProductHistoryUseCase>(),
    ),
  );
  getIt.registerFactory<ArchivedProductsViewModel>(
    () => ArchivedProductsViewModel(
      getIt<GetProductsUseCase>(),
      getIt<UnarchiveProductUseCase>(),
      getIt<DeleteProductPermanentlyUseCase>(),
    ),
  );
  getIt.registerFactory<ProductHistoryViewModel>(
    () => ProductHistoryViewModel(getIt<WatchProductHistoryUseCase>()),
  );
  getIt.registerFactory<ProductsFormViewModel>(
    () => ProductsFormViewModel(
      getIt<SaveProductUseCase>(),
      getIt<UpdateProductUseCase>(),
      getIt<ArchiveProductUseCase>(),
      getIt<UnarchiveProductUseCase>(),
      getIt<AdjustStockUseCase>(),
    ),
  );
}
