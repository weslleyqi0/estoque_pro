import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/core/di/service_locator.dart';
import 'package:estoque_pro/app/core/router/app_routes.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_permission.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_role.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () => getIt<AuthViewModel>().logoutCommand.execute(),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: getIt<AuthViewModel>(),
        builder: (context, _) {
          final currentUser = getIt<AuthViewModel>().currentUser;
          final isManager = currentUser?.role == UserRole.owner || currentUser?.role == UserRole.admin;

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isManager) ...[
                  AppButton(
                    onPressed: () => context.push(AppRoutes.users),
                    label: 'Gerenciar Usuários',
                  ),
                  const Gap(AppSpacing.space16),
                ],
                if (isManager || currentUser!.hasPermission(UserPermission.editProducts)) ...[
                  AppButton(
                    onPressed: () {
                      // TODO: Navegar para tela de vendas
                    },
                    label: 'Editar Produtos',
                  ),
                  const Gap(AppSpacing.space16),
                ],
                if (isManager || currentUser!.hasPermission(UserPermission.editSales)) ...[
                  AppButton(
                    onPressed: () {
                      // TODO: Navegar para tela de vendas
                    },
                    label: 'Nova Venda',
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
