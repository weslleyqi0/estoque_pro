import 'package:estoque_pro/app/core/di/modules/core_module.dart';
import 'package:estoque_pro/app/core/services/database_service.dart';
import 'package:estoque_pro/app/features/categories/data/repositories/categories_repository_impl.dart';
import 'package:estoque_pro/app/features/categories/domain/entities/category_entity.dart';
import 'package:estoque_pro/app/features/categories/domain/repositories/categories_repository.dart';
import 'package:estoque_pro/app/features/categories/domain/usecases/delete_category_use_case.dart';
import 'package:estoque_pro/app/features/categories/domain/usecases/get_categories_use_case.dart';
import 'package:estoque_pro/app/features/categories/domain/usecases/save_category_use_case.dart';
import 'package:estoque_pro/app/features/categories/domain/usecases/update_category_use_case.dart';
import 'package:estoque_pro/app/features/categories/presentation/viewmodels/categories_form_viewmodel.dart';
import 'package:estoque_pro/app/features/categories/presentation/viewmodels/categories_viewmodel.dart';
import 'package:estoque_pro/app/features/products/domain/usecases/count_products_use_case.dart';
import 'package:get_it/get_it.dart';

void setupCategoriesModule(GetIt getIt) {
  // Database Service
  registerDatabaseService<CategoryEntity>(getIt, 'categories');

  // Repositories
  getIt.registerLazySingleton<CategoriesRepository>(
    () => CategoriesRepositoryImpl(
      getIt<DatabaseService<CategoryEntity>>(),
    ),
  );

  // UseCases
  getIt.registerFactory<GetCategoriesUseCase>(
    () => GetCategoriesUseCase(getIt<CategoriesRepository>()),
  );
  getIt.registerFactory<SaveCategoryUseCase>(
    () => SaveCategoryUseCase(getIt<CategoriesRepository>()),
  );
  getIt.registerFactory<UpdateCategoryUseCase>(
    () => UpdateCategoryUseCase(getIt<CategoriesRepository>()),
  );
  getIt.registerFactory<DeleteCategoryUseCase>(
    () => DeleteCategoryUseCase(getIt<CategoriesRepository>()),
  );

  // ViewModels
  getIt.registerFactory<CategoriesViewModel>(
    () => CategoriesViewModel(
      getIt<GetCategoriesUseCase>(),
      getIt<CountProductsUseCase>(),
    ),
  );
  getIt.registerFactory<CategoriesFormViewmodel>(
    () => CategoriesFormViewmodel(
      getIt<SaveCategoryUseCase>(),
      getIt<UpdateCategoryUseCase>(),
      getIt<DeleteCategoryUseCase>(),
    ),
  );
}
