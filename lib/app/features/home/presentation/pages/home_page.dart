import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/core/router/app_routes.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:estoque_pro/app/features/deliveries/presentation/viewmodels/deliveries_viewmodel.dart';
import 'package:estoque_pro/app/features/home/presentation/widgets/home_alerts_section.dart';
import 'package:estoque_pro/app/features/home/presentation/widgets/home_button.dart';
import 'package:estoque_pro/app/features/products/presentation/viewmodels/products_viewmodel.dart';
import 'package:estoque_pro/app/features/sales/presentation/viewmodels/sales_viewmodel.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_role.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  final AuthViewModel authViewModel;
  final SalesViewModel Function() salesViewModelFactory;
  final ProductsViewModel Function() productsViewModelFactory;
  final DeliveriesViewModel Function() deliveriesViewModelFactory;

  const HomePage({
    super.key,
    required this.authViewModel,
    required this.salesViewModelFactory,
    required this.productsViewModelFactory,
    required this.deliveriesViewModelFactory,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final AuthViewModel _authVM;
  late final SalesViewModel _salesVM;
  late final ProductsViewModel _productsVM;
  late final DeliveriesViewModel _deliveriesVM;
  DateTime? _lastBackPressTime;

  @override
  void initState() {
    super.initState();
    _authVM = widget.authViewModel;
    _salesVM = widget.salesViewModelFactory();
    _productsVM = widget.productsViewModelFactory();
    _deliveriesVM = widget.deliveriesViewModelFactory();
    _salesVM.listenAll();
    _productsVM.listenAll();
    _deliveriesVM.listenAll();
  }

  @override
  void dispose() {
    _salesVM.dispose();
    _productsVM.dispose();
    _deliveriesVM.dispose();
    super.dispose();
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

  String get _currentFormattedDate {
    final now = DateTime.now();
    final raw = DateFormat("EEEE, d 'de' MMMM", 'pt_BR').format(now);
    final clean = raw.replaceAll('-feira', '');
    if (clean.isEmpty) return raw;
    return clean[0].toUpperCase() + clean.substring(1);
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
        listenable: Listenable.merge([_authVM, _salesVM, _productsVM, _deliveriesVM]),
        builder: (context, _) {
          final currentUser = _authVM.currentUser;
          final isManager = currentUser?.role == UserRole.owner || currentUser?.role == UserRole.admin;
          final inProgressSalesCount = _salesVM.inProgressSales.length;
          final lowStockCount = _productsVM.lowStockProducts.length;
          final delayedDeliveriesCount = _deliveriesVM.delayedDeliveries.length;
          final pendingDeliveriesCount = _deliveriesVM.pendingDeliveries.length;
          final pendingOrDelayedDeliveriesCount = delayedDeliveriesCount + pendingDeliveriesCount;
          final hasDelayedDeliveries = delayedDeliveriesCount > 0;

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
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- SEÇÃO FIXA: BOAS-VINDAS E DATA ---
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.space16,
                    vertical: AppSpacing.space4,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$_greetingPeriod • $_currentFormattedDate',
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colorScheme.onSurface.withValues(alpha: 0.6),
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

                // --- CARD FIXO: NOVA VENDA ---
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.space4, horizontal: AppSpacing.space12),
                  child: InkWell(
                    onTap: () => context.push(AppRoutes.newSale),
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
                ),

                // --- CONTEÚDO ROLÁVEL (Avisos e Botões) ---
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: HomeAlertsSection(
                          delayedDeliveriesCount: delayedDeliveriesCount,
                          pendingDeliveriesCount: pendingDeliveriesCount,
                          inProgressSalesCount: inProgressSalesCount,
                          lowStockProductsCount: lowStockCount,
                          onLowStockTap: () => context.push(AppRoutes.products, extra: true),
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
                            crossAxisSpacing: AppSpacing.space8,
                            childAspectRatio: 1.35,
                          ),
                          delegate: SliverChildListDelegate([
                            HomeButton(
                              title: 'Produtos',
                              subTitle: 'Gerenciar Catalogo',
                              badgerContent: lowStockCount > 0 ? '$lowStockCount' : null,
                              badgerColor: AppColors.warning,
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
                              badgerContent: inProgressSalesCount > 0 ? '$inProgressSalesCount' : null,
                              badgerColor: AppColors.warning,
                              color: Colors.green,
                              icon: AppIcons.orderApprove,
                              onPressed: () => context.push(
                                AppRoutes.sales,
                                extra: SalesFilterTab.all,
                              ),
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
                              onPressed: () => context.push(AppRoutes.customers),
                            ),
                            HomeButton(
                              title: 'Entregas',
                              subTitle: 'Gerenciar entregas',
                              badgerContent:
                                  pendingOrDelayedDeliveriesCount > 0 ? '$pendingOrDelayedDeliveriesCount' : null,
                              badgerColor: hasDelayedDeliveries ? AppColors.error : AppColors.warning,
                              color: Colors.orange,
                              icon: AppIcons.deliveryTruck,
                              onPressed: () => context.push(
                                AppRoutes.deliveries,
                                extra: DeliveryFilterTab.all,
                              ),
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
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
