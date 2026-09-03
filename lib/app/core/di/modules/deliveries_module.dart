import 'package:estoque_pro/app/core/di/modules/core_module.dart';
import 'package:estoque_pro/app/core/services/database_service.dart';
import 'package:estoque_pro/app/features/deliveries/data/repositories/deliveries_repository_impl.dart';
import 'package:estoque_pro/app/features/deliveries/domain/entities/delivery_entity.dart';
import 'package:estoque_pro/app/features/deliveries/domain/repositories/deliveries_repository.dart';
import 'package:estoque_pro/app/features/deliveries/domain/usecases/delete_delivery_use_case.dart';
import 'package:estoque_pro/app/features/deliveries/domain/usecases/get_deliveries_use_case.dart';
import 'package:estoque_pro/app/features/deliveries/domain/usecases/save_delivery_use_case.dart';
import 'package:estoque_pro/app/features/deliveries/domain/usecases/update_delivery_status_use_case.dart';
import 'package:estoque_pro/app/features/deliveries/domain/usecases/update_delivery_use_case.dart';
import 'package:estoque_pro/app/features/deliveries/presentation/viewmodels/deliveries_viewmodel.dart';
import 'package:estoque_pro/app/features/sales/domain/repositories/sales_repository.dart';
import 'package:get_it/get_it.dart';

void setupDeliveriesModule(GetIt getIt) {
  // Database Service
  registerDatabaseService<DeliveryEntity>(getIt, 'deliveries');

  // Repositories
  getIt.registerLazySingleton<DeliveriesRepository>(
    () => DeliveriesRepositoryImpl(
      getIt<DatabaseService<DeliveryEntity>>(),
    ),
  );

  // UseCases
  getIt.registerFactory<GetDeliveriesUseCase>(
    () => GetDeliveriesUseCase(getIt<DeliveriesRepository>()),
  );
  getIt.registerFactory<SaveDeliveryUseCase>(
    () => SaveDeliveryUseCase(getIt<DeliveriesRepository>()),
  );
  getIt.registerFactory<UpdateDeliveryUseCase>(
    () => UpdateDeliveryUseCase(
      getIt<DeliveriesRepository>(),
      getIt<SalesRepository>(),
    ),
  );
  getIt.registerFactory<UpdateDeliveryStatusUseCase>(
    () => UpdateDeliveryStatusUseCase(getIt<DeliveriesRepository>()),
  );
  getIt.registerFactory<DeleteDeliveryUseCase>(
    () => DeleteDeliveryUseCase(getIt<DeliveriesRepository>()),
  );

  // ViewModels
  getIt.registerFactory<DeliveriesViewModel>(
    () => DeliveriesViewModel(
      getIt<GetDeliveriesUseCase>(),
      getIt<SaveDeliveryUseCase>(),
      getIt<UpdateDeliveryUseCase>(),
      getIt<UpdateDeliveryStatusUseCase>(),
      getIt<DeleteDeliveryUseCase>(),
    ),
  );
}
