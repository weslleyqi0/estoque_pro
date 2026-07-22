import 'package:estoque_pro/app/features/users/domain/entities/user_entity.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_permission.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_role.dart';

const fakeOwnerUser = UserEntity(
  uid: 'owner_123',
  name: 'Owner',
  email: 'owner@test.com',
  role: UserRole.owner,
  isActive: true,
  permissions: {},
);

final fakeAdminUser = UserEntity(
  uid: 'admin_123',
  name: 'Admin',
  email: 'admin@test.com',
  role: UserRole.admin,
  isActive: true,
  permissions: UserPermission.values.toSet(),
);

const fakeSellerUser = UserEntity(
  uid: 'seller_123',
  name: 'Seller',
  email: 'seller@test.com',
  role: UserRole.seller,
  isActive: true,
  permissions: {
    UserPermission.changeSalePrice,
    UserPermission.editProducts,
    UserPermission.editSales,
    UserPermission.manageCategories,
    UserPermission.manageStock,
    UserPermission.manageSuppliers,
  },
);

const fakeInactiveOwnerUser = UserEntity(
  uid: 'owner_123',
  name: 'Owner',
  email: 'owner@test.com',
  role: UserRole.owner,
  isActive: false,
  permissions: {},
);

const fakeInactiveAdminUser = UserEntity(
  uid: 'admin_123',
  name: 'Admin',
  email: 'admin@test.com',
  role: UserRole.admin,
  isActive: false,
  permissions: {},
);

const fakeInactiveSellerUser = UserEntity(
  uid: 'seller_123',
  name: 'Seller',
  email: 'seller@test.com',
  role: UserRole.seller,
  isActive: false,
  permissions: {
    UserPermission.changeSalePrice,
    UserPermission.editProducts,
    UserPermission.editSales,
    UserPermission.manageCategories,
    UserPermission.manageStock,
    UserPermission.manageSuppliers,
  },
);
