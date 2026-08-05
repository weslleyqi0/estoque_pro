import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/core/di/service_locator.dart';
import 'package:estoque_pro/app/core/router/app_routes.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:estoque_pro/app/features/home/presentation/widgets/home_button.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_role.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

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

          return Column(
            children: [
              Container(
                width: double.infinity,
                margin: .symmetric(horizontal: AppSpacing.radius16),
                decoration: BoxDecoration(
                  color: context.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(AppSpacing.radius24),
                ),
                child: Padding(
                  padding: const .all(AppSpacing.space24),
                  child: Row(
                    mainAxisAlignment: .start,
                    crossAxisAlignment: .center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.space16),
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.2),
                          borderRadius: AppSpacing.borderRadius12,
                        ),
                        child: Icon(
                          Symbols.add_2_rounded,
                          color: AppColors.white,
                          size: AppSpacing.icon28,
                          weight: 600,
                        ),
                      ),
                      const Gap(AppSpacing.space12),
                      Column(
                        mainAxisAlignment: .center,
                        crossAxisAlignment: .start,
                        children: [
                          Text(
                            'Nova Venda',
                            style: context.textTheme.headlineSmall?.copyWith(color: AppColors.white, height: 0.9),
                          ),
                          Text(
                            'Iniciar uma nova venda',
                            style: context.textTheme.bodyMedium?.copyWith(color: AppColors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const Gap(AppSpacing.space16),
              Flexible(
                child: GridView(
                  padding: .symmetric(horizontal: AppSpacing.space12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: AppSpacing.space4,
                    crossAxisSpacing: AppSpacing.space4,
                    childAspectRatio: 1.35,
                  ),
                  children: [
                    HomeButton(
                      title: 'Produtos',
                      subTitle: 'Gerenciar Catalogo',
                      color: AppColors.primary,
                      icon: Symbols.lists_rounded,
                      onPressed: () => context.push(AppRoutes.products),
                    ),
                    HomeButton(
                      title: 'Vendas',
                      subTitle: 'Histórico e andamento',
                      color: Colors.green,
                      icon: Symbols.order_approve_sharp,
                      onPressed: () {},
                    ),

                    HomeButton(
                      title: 'Categorias',
                      subTitle: 'Organizar produtos',
                      color: Colors.deepPurple,
                      icon: Symbols.stacks_rounded,
                      onPressed: () => context.push(AppRoutes.categories),
                    ),
                    HomeButton(
                      title: 'Fornecedores',
                      subTitle: 'Gerenciar paceiros',
                      color: Colors.cyan,
                      icon: Symbols.local_shipping_rounded,
                      onPressed: () => context.push(AppRoutes.suppliers),
                    ),
                    HomeButton(
                      title: 'Clientes',
                      subTitle: 'Cadastros e fiados',
                      color: Colors.pink,
                      icon: Symbols.group_rounded,
                      onPressed: () {},
                    ),
                    HomeButton(
                      title: 'Entregas',
                      subTitle: 'Gerenciar entregas',
                      color: Colors.orange,
                      icon: Symbols.delivery_truck_speed_rounded,
                      onPressed: () {},
                    ),
                    if (isManager) ...[
                      HomeButton(
                        title: 'Relatórios',
                        subTitle: 'Análise completa',
                        color: Colors.blue,
                        icon: Symbols.bar_chart_rounded,
                        onPressed: () {},
                      ),
                      HomeButton(
                        title: 'Usuários',
                        subTitle: 'Gerenciar equipe',
                        color: Colors.blueGrey,
                        icon: Symbols.supervisor_account_rounded,
                        onPressed: () => context.push(AppRoutes.users),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
