import 'package:estoque_pro/app/features/authorization/domain/entities/app_permission.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../fakes/fake_users.dart';

void main() {
  group(
    'User Entity Tests',
    () {
      test('should owner role has all permissions and is active by default', () {
        const user = fakeOwnerUser;

        expect(user.hasPermission(AppPermission.changeSalePrice), isTrue);
        expect(user.hasPermission(AppPermission.deleteProducts), isTrue);
        expect(user.hasPermission(AppPermission.editProducts), isTrue);
        expect(user.hasPermission(AppPermission.editSales), isTrue);
        expect(user.hasPermission(AppPermission.manageCategories), isTrue);
        expect(user.hasPermission(AppPermission.manageStock), isTrue);
        expect(user.hasPermission(AppPermission.manageSuppliers), isTrue);
        expect(user.hasPermission(AppPermission.manageUsers), isTrue);
        expect(user.hasPermission(AppPermission.viewReports), isTrue);
      });

      test('should admin role has all permissions and is active by default', () {
        final user = fakeAdminUser;

        expect(user.hasPermission(AppPermission.changeSalePrice), isTrue);
        expect(user.hasPermission(AppPermission.deleteProducts), isTrue);
        expect(user.hasPermission(AppPermission.editProducts), isTrue);
        expect(user.hasPermission(AppPermission.editSales), isTrue);
        expect(user.hasPermission(AppPermission.manageCategories), isTrue);
        expect(user.hasPermission(AppPermission.manageStock), isTrue);
        expect(user.hasPermission(AppPermission.manageSuppliers), isTrue);
        expect(user.hasPermission(AppPermission.manageUsers), isTrue);
        expect(user.hasPermission(AppPermission.viewReports), isTrue);
      });

      test('should seller role has only assigned permissions', () {
        const user = fakeSellerUser;

        expect(user.hasPermission(AppPermission.changeSalePrice), isTrue);
        expect(user.hasPermission(AppPermission.editProducts), isTrue);
        expect(user.hasPermission(AppPermission.editSales), isTrue);
        expect(user.hasPermission(AppPermission.manageCategories), isTrue);
        expect(user.hasPermission(AppPermission.manageStock), isTrue);
        expect(user.hasPermission(AppPermission.manageSuppliers), isTrue);
        expect(user.hasPermission(AppPermission.manageUsers), isFalse);
        expect(user.hasPermission(AppPermission.viewReports), isFalse);
      });

      test('Inactive user has no permissions, even if role is admin or owner', () {
        const owner = fakeInactiveOwnerUser;
        const admin = fakeInactiveAdminUser;
        const seller = fakeInactiveSellerUser;

        expect(owner.hasPermission(AppPermission.manageUsers), isFalse);
        expect(admin.hasPermission(AppPermission.manageUsers), isFalse);
        expect(seller.hasPermission(AppPermission.editProducts), isFalse);
      });
    },
  );
}
