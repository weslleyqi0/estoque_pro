import 'package:estoque_pro/app/features/users/domain/entities/user_permission.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../fakes/fake_users.dart';

void main() {
  group(
    'User Entity Tests',
    () {
      test('should owner role has all permissions and is active by default', () {
        const user = fakeOwnerUser;

        expect(user.hasPermission(UserPermission.changeSalePrice), isTrue);
        expect(user.hasPermission(UserPermission.deleteProducts), isTrue);
        expect(user.hasPermission(UserPermission.editProducts), isTrue);
        expect(user.hasPermission(UserPermission.editSales), isTrue);
        expect(user.hasPermission(UserPermission.manageCategories), isTrue);
        expect(user.hasPermission(UserPermission.manageStock), isTrue);
        expect(user.hasPermission(UserPermission.manageSuppliers), isTrue);
        expect(user.hasPermission(UserPermission.viewReports), isTrue);
      });

      test('should admin role has all permissions and is active by default', () {
        final user = fakeAdminUser;

        expect(user.hasPermission(UserPermission.changeSalePrice), isTrue);
        expect(user.hasPermission(UserPermission.deleteProducts), isTrue);
        expect(user.hasPermission(UserPermission.editProducts), isTrue);
        expect(user.hasPermission(UserPermission.editSales), isTrue);
        expect(user.hasPermission(UserPermission.manageCategories), isTrue);
        expect(user.hasPermission(UserPermission.manageStock), isTrue);
        expect(user.hasPermission(UserPermission.manageSuppliers), isTrue);
        expect(user.hasPermission(UserPermission.viewReports), isTrue);
      });

      test('should seller role has only assigned permissions', () {
        const user = fakeSellerUser;

        expect(user.hasPermission(UserPermission.changeSalePrice), isTrue);
        expect(user.hasPermission(UserPermission.editProducts), isTrue);
        expect(user.hasPermission(UserPermission.editSales), isTrue);
        expect(user.hasPermission(UserPermission.manageCategories), isTrue);
        expect(user.hasPermission(UserPermission.manageStock), isTrue);
        expect(user.hasPermission(UserPermission.manageSuppliers), isTrue);
        expect(user.hasPermission(UserPermission.viewReports), isFalse);
      });

      test('Inactive user has no permissions, even if role is admin or owner', () {
        const seller = fakeInactiveSellerUser;

        expect(seller.hasPermission(UserPermission.editProducts), isFalse);
      });
    },
  );
}
