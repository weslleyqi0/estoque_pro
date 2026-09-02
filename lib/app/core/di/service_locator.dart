import 'package:estoque_pro/app/core/di/modules/auth_module.dart';
import 'package:estoque_pro/app/core/di/modules/categories_module.dart';
import 'package:estoque_pro/app/core/di/modules/core_module.dart';
import 'package:estoque_pro/app/core/di/modules/customers_module.dart';
import 'package:estoque_pro/app/core/di/modules/deliveries_module.dart';
import 'package:estoque_pro/app/core/di/modules/products_module.dart';
import 'package:estoque_pro/app/core/di/modules/reports_module.dart';
import 'package:estoque_pro/app/core/di/modules/sales_module.dart';
import 'package:estoque_pro/app/core/di/modules/suppliers_module.dart';
import 'package:estoque_pro/app/core/di/modules/users_module.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  await setupCoreModule(getIt);
  setupUsersModule(getIt);
  setupAuthModule(getIt);
  setupCategoriesModule(getIt);
  setupSuppliersModule(getIt);
  setupCustomersModule(getIt);
  setupProductsModule(getIt);
  setupDeliveriesModule(getIt);
  setupSalesModule(getIt);
  setupReportsModule(getIt);
}
