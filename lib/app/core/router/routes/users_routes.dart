import 'package:estoque_pro/app/core/di/service_locator.dart';
import 'package:estoque_pro/app/core/router/app_routes.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_entity.dart';
import 'package:estoque_pro/app/features/users/presentation/pages/user_form_page.dart';
import 'package:estoque_pro/app/features/users/presentation/pages/users_page.dart';
import 'package:estoque_pro/app/features/users/presentation/viewmodels/user_form_viewmodel.dart';
import 'package:estoque_pro/app/features/users/presentation/viewmodels/users_viewmodel.dart';
import 'package:go_router/go_router.dart';

List<GoRoute> usersRoutes() {
  return [
    GoRoute(
      path: AppRoutes.users,
      builder: (context, state) => UsersPage(
        viewModelFactory: () => getIt<UsersViewModel>(),
      ),
    ),
    GoRoute(
      path: AppRoutes.userForm,
      builder: (context, state) {
        final user = state.extra as UserEntity?;
        return UserFormPage(
          viewModelFactory: () => getIt<UserFormViewModel>(),
          user: user,
        );
      },
    ),
  ];
}
