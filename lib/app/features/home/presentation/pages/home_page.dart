import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/core/router/app_routes.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:estoque_pro/app/features/home/presentation/widgets/home_button.dart';
import 'package:estoque_pro/app/features/products/presentation/viewmodels/products_viewmodel.dart';
import 'package:estoque_pro/app/features/sales/presentation/viewmodels/sales_viewmodel.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_role.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatefulWidget {
  final AuthViewModel authViewModel;
  final SalesViewModel salesViewModel;
  final ProductsViewModel productsViewModel;

  const HomePage({
    super.key,
    required this.authViewModel,
    required this.salesViewModel,
    required this.productsViewModel,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  AuthViewModel get _authVM => widget.authViewModel;
  SalesViewModel get _salesVM => widget.salesViewModel;
  ProductsViewModel get _productsVM => widget.productsViewModel;
  DateTime? _lastBackPressTime;

  @override
  void initState() {
    super.initState();
    _salesVM.listenAll();
    _productsVM.listenAll();
  }

  String get _greetingPeriod {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'Bom dia';
    } else if (hour >= 12 && hour < 18) {
      return 'Boa tarde';
    } else {
      return 'Boa noite';
    }
  }

  String _userFirstName(String? name) {
    if (name == null || name.trim().isEmpty) return 'Usuário';
    return name.trim().split(' ').first;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        final now = DateTime.now();
        if (_lastBackPressTime == null || now.difference(_lastBackPressTime!) > const Duration(milliseconds: 1500)) {
          _lastBackPressTime = now;
          AppSnackbar.info(context, 'Toque novamente para sair do aplicativo');
        } else {
          SystemNavigator.pop();
        }
      },
      child: ListenableBuilder(
        listenable: Listenable.merge([_authVM, _salesVM, _productsVM]),
        builder: (context, _) {
          final currentUser = _authVM.currentUser;
          final isManager = currentUser?.role == UserRole.owner || currentUser?.role == UserRole.admin;
          final allInProgressSales = _salesVM.inProgressSales;
          final lowStockProducts = _productsVM.lowStockProducts;

          return Scaffold(
            appBar: AppBar(
              title: const Text('Home'),
              actions: [
                AppIconButton(
                  icon: AppIcons.settings,
                  tooltip: 'Configurações',
                  onPressed: () => context.push(AppRoutes.settings),
                ),
                const Gap(AppSpacing.space8),
              ],
            ),
            body: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.space16,
                      vertical: AppSpacing.space4,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _greetingPeriod,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.colorScheme.onSurface.withValues(alpha: 0.6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'Olá, ${_userFirstName(currentUser?.name)} 👋',
                          style: context.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _PinnedNovaVendaDelegate(
                    onTap: () => context.push(AppRoutes.newSale),
                  ),
                ),
                if (allInProgressSales.isNotEmpty || lowStockProducts.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Gap(AppSpacing.space8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
                          child: Text('Avisos', style: context.textTheme.titleMedium),
                        ),
                        const Gap(AppSpacing.space4),
                        if (allInProgressSales.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space12),
                            child: AppInfoBanner(
                              title: allInProgressSales.length == 1
                                  ? '1 venda aguardando finalização'
                                  : '${allInProgressSales.length} vendas aguardando finalização',
                              subtitle: 'Toque para ver ou gerenciar as vendas em andamento',
                              icon: AppIcons.shoppingCart,
                              type: AppInfoBannerType.warning,
                              onTap: () {
                                _salesVM.setSelectedTab(SalesFilterTab.inProgress);
                                context.push(AppRoutes.sales);
                              },
                            ),
                          ),
                          const Gap(AppSpacing.space12),
                        ],
                        if (lowStockProducts.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space12),
                            child: AppInfoBanner(
                              title: lowStockProducts.length == 1
                                  ? '1 produto com estoque baixo'
                                  : '${lowStockProducts.length} produtos com estoque baixo',
                              subtitle: 'Toque para gerenciar o estoque dos produtos',
                              icon: AppIcons.package2,
                              type: AppInfoBannerType.error,
                              onTap: () {
                                _productsVM.setShowOnlyLowStock(true);
                                context.push(AppRoutes.products);
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                const SliverToBoxAdapter(
                  child: Gap(AppSpacing.space16),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space12),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: AppSpacing.space12,
                      mainAxisSpacing: AppSpacing.space12,
                      childAspectRatio: 1.35,
                    ),
                    delegate: SliverChildListDelegate([
                      HomeButton(
                        title: 'Produtos',
                        subTitle: 'Gerenciar Catalogo',
                        badgerContent: lowStockProducts.isNotEmpty ? '${lowStockProducts.length}' : null,
                        badgerColor: AppColors.error,
                        color: AppColors.primary,
                        icon: AppIcons.lists,
                        onPressed: () {
                          _productsVM.setShowOnlyLowStock(false);
                          context.push(AppRoutes.products);
                        },
                      ),
                      HomeButton(
                        title: 'Vendas',
                        subTitle: 'Histórico e andamento',
                        badgerContent: allInProgressSales.isNotEmpty ? '${allInProgressSales.length}' : null,
                        badgerColor: AppColors.warning,
                        color: Colors.green,
                        icon: AppIcons.orderApprove,
                        onPressed: () {
                          _salesVM.setSelectedTab(SalesFilterTab.all);
                          context.push(AppRoutes.sales);
                        },
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
                        subTitle: 'Gerenciar parceiros',
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
                    ]),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: Gap(AppSpacing.space24),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PinnedNovaVendaDelegate extends SliverPersistentHeaderDelegate {
  final VoidCallback onTap;

  const _PinnedNovaVendaDelegate({required this.onTap});

  @override
  double get minExtent => 116.0;

  @override
  double get maxExtent => 116.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: context.colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space12, vertical: AppSpacing.space8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radius24),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: context.colorScheme.primary,
            borderRadius: BorderRadius.circular(AppSpacing.radius24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.space20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
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
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nova Venda',
                        style: context.textTheme.headlineSmall?.copyWith(
                          color: AppColors.white,
                          height: 0.9,
                        ),
                      ),
                      Text(
                        'Iniciar uma nova venda',
                        style: context.textTheme.labelMedium?.copyWith(
                          color: AppColors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _PinnedNovaVendaDelegate oldDelegate) => false;
}
