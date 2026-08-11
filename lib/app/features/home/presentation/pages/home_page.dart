import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/core/di/service_locator.dart';
import 'package:estoque_pro/app/core/router/app_routes.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:estoque_pro/app/features/home/presentation/widgets/home_button.dart';
import 'package:estoque_pro/app/features/sales/presentation/viewmodels/sales_viewmodel.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_role.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _authVM = getIt<AuthViewModel>();
  final _salesVM = getIt<SalesViewModel>();

  @override
  void initState() {
    super.initState();
    _salesVM.listenAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(AppIcons.logout),
            tooltip: 'Sair',
            onPressed: () => _authVM.logoutCommand.execute(),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([_authVM, _salesVM]),
        builder: (context, _) {
          final currentUser = _authVM.currentUser;
          final isManager = currentUser?.role == UserRole.owner || currentUser?.role == UserRole.admin;
          final allInProgressSales = _salesVM.inProgressSales;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space12),
                child: InkWell(
                  onTap: () => context.push(AppRoutes.newSale),
                  borderRadius: BorderRadius.circular(AppSpacing.radius24),
                  child: Container(
                    width: double.infinity,
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
                              AppIcons.add2,
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
                ),
              ),
              if (allInProgressSales.isNotEmpty) ...[
                const Gap(AppSpacing.space12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space12),
                  child: AppInfoBanner(
                    title: allInProgressSales.length == 1
                        ? '1 venda aguardando finalização'
                        : '${allInProgressSales.length} vendas aguardando finalização',
                    subtitle: 'Toque para ver ou gerenciar as vendas em andamento',
                    icon: Symbols.shopping_cart_rounded,
                    type: AppInfoBannerType.warning,
                    onTap: () => context.push(AppRoutes.sales),
                  ),
                ),
              ],
              const Gap(AppSpacing.space16),
              Flexible(
                child: GridView(
                  padding: .symmetric(horizontal: AppSpacing.space12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: AppSpacing.space8,
                    childAspectRatio: 1.35,
                  ),
                  children: [
                    HomeButton(
                      title: 'Produtos',
                      subTitle: 'Gerenciar Catalogo',
                      color: AppColors.primary,
                      icon: AppIcons.lists,
                      onPressed: () => context.push(AppRoutes.products),
                    ),
                    HomeButton(
                      title: 'Vendas',
                      subTitle: 'Histórico e andamento',
                      badgerContent: allInProgressSales.isNotEmpty ? '${allInProgressSales.length}' : null,
                      badgerColor: AppColors.warning,
                      color: Colors.green,
                      icon: AppIcons.orderApprove,
                      onPressed: () => context.push(AppRoutes.sales),
                    ),

                    HomeButton(
                      title: 'Categorias',
                      subTitle: 'Organizar produtos',
                      color: Colors.deepPurple,
                      icon: AppIcons.stacks,
                      onPressed: () => context.push(AppRoutes.categories),
                    ),
                    HomeButton(
                      title: 'Fornecedores',
                      subTitle: 'Gerenciar paceiros',
                      color: Colors.cyan,
                      icon: AppIcons.localShipping,
                      onPressed: () => context.push(AppRoutes.suppliers),
                    ),
                    HomeButton(
                      title: 'Clientes',
                      subTitle: 'Cadastros e fiados',
                      color: Colors.pink,
                      icon: AppIcons.group,
                      onPressed: () {},
                    ),
                    HomeButton(
                      title: 'Entregas',
                      subTitle: 'Gerenciar entregas',
                      color: Colors.orange,
                      icon: AppIcons.deliveryTruck,
                      onPressed: () {},
                    ),
                    if (isManager) ...[
                      HomeButton(
                        title: 'Relatórios',
                        subTitle: 'Análise completa',
                        color: Colors.blue,
                        icon: AppIcons.barChart,
                        onPressed: () {},
                      ),
                      HomeButton(
                        title: 'Usuários',
                        subTitle: 'Gerenciar equipe',
                        color: Colors.blueGrey,
                        icon: AppIcons.supervisorAccount,
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
