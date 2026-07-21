import 'package:estoque_pro/app/features/authorization/domain/entities/app_permission.dart';
import 'package:estoque_pro/app/features/authorization/domain/entities/app_role.dart';
import 'package:estoque_pro/app/features/authorization/user_entity.dart';

const fakeOwnerUser = UserEntity(
  uid: 'owner_123',
  name: 'Owner',
  email: 'owner@test.com',
  role: AppRole.owner,
  isActive: true,
  permissions: [],
);

const fakeAdminUser = UserEntity(
  uid: 'admin_123',
  name: 'Admin',
  email: 'admin@test.com',
  role: AppRole.admin,
  isActive: true,
  permissions: AppPermission.values,
);

const fakeSellerUser = UserEntity(
  uid: 'seller_123',
  name: 'Seller',
  email: 'seller@test.com',
  role: AppRole.seller,
  isActive: true,
  permissions: [
    AppPermission.changeSalePrice,
    AppPermission.editProducts,
    AppPermission.editSales,
    AppPermission.manageCategories,
    AppPermission.manageStock,
    AppPermission.manageSuppliers,
  ],
);

const fakeInactiveOwnerUser = UserEntity(
  uid: 'owner_123',
  name: 'Owner',
  email: 'owner@test.com',
  role: AppRole.owner,
  isActive: false,
  permissions: [],
);

const fakeInactiveAdminUser = UserEntity(
  uid: 'admin_123',
  name: 'Admin',
  email: 'admin@test.com',
  role: AppRole.admin,
  isActive: false,
  permissions: [],
);

const fakeInactiveSellerUser = UserEntity(
  uid: 'seller_123',
  name: 'Seller',
  email: 'seller@test.com',
  role: AppRole.seller,
  isActive: false,
  permissions: [
    AppPermission.changeSalePrice,
    AppPermission.editProducts,
    AppPermission.editSales,
    AppPermission.manageCategories,
    AppPermission.manageStock,
    AppPermission.manageSuppliers,
  ],
);
