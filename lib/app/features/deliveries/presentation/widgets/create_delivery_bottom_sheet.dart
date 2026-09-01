import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/core/utils/currency_input_formatter.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:estoque_pro/app/features/customers/domain/repositories/customers_repository.dart';
import 'package:estoque_pro/app/features/deliveries/presentation/viewmodels/deliveries_viewmodel.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_status.dart';
import 'package:estoque_pro/app/features/sales/domain/repositories/sales_repository.dart';
import 'package:estoque_pro/app/features/sales/presentation/widgets/payment_delivery_schedule_card.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class CreateDeliveryBottomSheet extends StatefulWidget {
  final DeliveriesViewModel deliveriesViewModel;
  final AuthViewModel authViewModel;
  final SalesRepository? salesRepository;
  final CustomersRepository? customersRepository;
  final SaleEntity? initialSale;

  const CreateDeliveryBottomSheet({
    super.key,
    required this.deliveriesViewModel,
    required this.authViewModel,
    this.salesRepository,
    this.customersRepository,
    this.initialSale,
  });

  static Future<void> show({
    required BuildContext context,
    required DeliveriesViewModel deliveriesViewModel,
    required AuthViewModel authViewModel,
    SalesRepository? salesRepository,
    CustomersRepository? customersRepository,
    SaleEntity? initialSale,
  }) {
    return AppBottomSheet.show(
      context: context,
      isScrollControlled: true,
      builder: (_) => CreateDeliveryBottomSheet(
        deliveriesViewModel: deliveriesViewModel,
        authViewModel: authViewModel,
        salesRepository: salesRepository,
        customersRepository: customersRepository,
        initialSale: initialSale,
      ),
    );
  }

  @override
  State<CreateDeliveryBottomSheet> createState() => _CreateDeliveryBottomSheetState();
}

class _CreateDeliveryBottomSheetState extends State<CreateDeliveryBottomSheet> {
  SaleEntity? _selectedSale;
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();
  final _searchController = TextEditingController();

  late DateTime _scheduledDate;
  bool _isLoading = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _scheduledDate = DateTime.now().add(const Duration(hours: 1));
    if (widget.initialSale != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _onSaleSelected(widget.initialSale!);
        }
      });
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSaleSelected(SaleEntity sale) async {
    setState(() {
      _selectedSale = sale;
      _addressController.clear();
      _phoneController.clear();
    });

    if (sale.customerId != null && sale.customerId!.isNotEmpty && widget.customersRepository != null) {
      try {
        final result = await widget.customersRepository!.getAll();
        final customers = result.value ?? [];
        final customer = customers.where((c) => c.id == sale.customerId).firstOrNull;
        if (customer != null) {
          if (customer.address != null && customer.address!.isNotEmpty) {
            _addressController.text = customer.address!;
          }
          if (customer.phone != null && customer.phone!.isNotEmpty) {
            _phoneController.text = customer.phone!;
          }
        }
      } catch (_) {}
    }
  }

  void _pickScheduleDate() async {
    final now = DateTime.now();
    final pickedDateTime = await AppDateTimePicker.show(
      context: context,
      title: 'Agendamento da Entrega',
      initialDate: _scheduledDate.isAfter(now) ? _scheduledDate : now.add(const Duration(hours: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      invalidTimeMessage: 'Fora do nosso horário de entrega',
      is24HourMode: true,
      isShowSeconds: false,
      minutesInterval: 10,
    );

    if (pickedDateTime != null) {
      setState(() {
        _scheduledDate = pickedDateTime;
      });
    }
  }

  Future<void> _submitDelivery() async {
    if (_addressController.text.trim().isEmpty) {
      AppSnackbar.error(context, 'Por favor, informe o endereço de entrega.');
      return;
    }

    if (_selectedSale == null) return;

    final currentUser = widget.authViewModel.currentUser;
    if (currentUser == null) {
      AppSnackbar.error(context, 'Usuário não autenticado.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await widget.deliveriesViewModel.createDelivery(
        sale: _selectedSale!,
        customerAddress: _addressController.text.trim(),
        customerPhone: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
        scheduledAt: _scheduledDate,
        observations: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
        userId: currentUser.uid,
        userName: currentUser.name,
      );

      if (mounted) {
        Navigator.pop(context);
        AppSnackbar.success(
          context,
          'Entrega para a venda #${_selectedSale!.saleNumber} criada com sucesso!',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppSnackbar.error(context, e.toString().replaceAll('Exception: ', ''));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (context, scrollController) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: _selectedSale == null
                ? _buildSaleSelectionView(scrollController)
                : _buildDeliveryFormView(scrollController),
          ),
        );
      },
    );
  }

  Widget _buildSaleSelectionView(ScrollController scrollController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(
              top: AppSpacing.space16,
              bottom: AppSpacing.space12,
            ),
            decoration: BoxDecoration(
              color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.space16, 0, AppSpacing.space16, AppSpacing.space8),
          child: Row(
            crossAxisAlignment: .start,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.space12),
                decoration: BoxDecoration(
                  color: context.colorScheme.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  AppIcons.truck,
                  size: AppSpacing.icon24,
                  color: context.colorScheme.primary,
                ),
              ),
              const Gap(AppSpacing.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selecionar Venda',
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Escolha uma venda sem entrega para agendar',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(AppIcons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.space16),
          child: AppTextfield(
            controller: _searchController,
            hint: 'Buscar venda por número, cliente...',
            prefixIcon: AppIcons.search,
            onChanged: (value) => setState(() => _searchQuery = value.trim().toLowerCase()),
          ),
        ),
        Expanded(
          child: widget.salesRepository == null
              ? const SizedBox.shrink()
              : StreamBuilder<List<SaleEntity>>(
                  stream: widget.salesRepository!.watchAll(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(AppSpacing.space32),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

              final allSales = snapshot.data ?? [];
              final existingDeliveries = widget.deliveriesViewModel.deliveries;

              final eligibleSales = allSales
                  .where((s) {
                    if (s.status == SaleStatus.cancelled) return false;
                    final alreadyHasDelivery = existingDeliveries.any(
                      (d) =>
                          (d.saleId.isNotEmpty && d.saleId == s.id) ||
                          (s.saleNumber.isNotEmpty && d.saleNumber == s.saleNumber),
                    );
                    return !alreadyHasDelivery;
                  })
                  .where((s) {
                    if (_searchQuery.isEmpty) return true;
                    final matchNum = s.saleNumber.toLowerCase().contains(_searchQuery);
                    final matchCust = s.customerName?.toLowerCase().contains(_searchQuery) ?? false;
                    final matchSeller = s.userName.toLowerCase().contains(_searchQuery);
                    return matchNum || matchCust || matchSeller;
                  })
                  .toList();

              if (eligibleSales.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.space32, horizontal: AppSpacing.space16),
                  child: AppEmptyList(
                    icon: AppIcons.truck,
                    iconColor: Colors.orange,
                    message:
                        'Nenhuma venda disponível sem entrega.\nTodas as vendas ativas já possuem uma entrega vinculada.',
                  ),
                );
              }

              return ListView.separated(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(AppSpacing.space16, 0, AppSpacing.space16, AppSpacing.space16),
                itemCount: eligibleSales.length,
                separatorBuilder: (_, _) => const Gap(AppSpacing.space8),
                itemBuilder: (context, index) {
                  final sale = eligibleSales[index];
                  return _buildSaleCard(sale);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSaleCard(SaleEntity sale) {
    final formattedDate = DateFormat("dd/MM/yyyy 'às' HH:mm", 'pt_BR').format(sale.createdAt);
    final itemsCount = sale.items.fold<int>(0, (sum, item) => sum + item.quantity);
    final itemsDescription = sale.items.map((i) => '${i.quantity}x ${i.productName}').join(', ');

    return InkWell(
      onTap: () => _onSaleSelected(sale),
      borderRadius: BorderRadius.circular(AppSpacing.radius12),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.space12),
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppSpacing.radius12),
          border: Border.all(
            color: context.colorScheme.outlineVariant,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppTag(
                  title: '#${sale.saleNumber}',
                  color: context.colorScheme.primary,
                ),
                Text(
                  formattedDate,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const Gap(AppSpacing.space8),
            Row(
              children: [
                Icon(
                  AppIcons.person,
                  size: AppSpacing.icon16,
                  color: context.colorScheme.primary,
                ),
                const Gap(AppSpacing.space4),
                Expanded(
                  child: Text(
                    sale.customerName?.isNotEmpty == true ? sale.customerName! : 'Cliente Avulso / Balcão',
                    style: context.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  CurrencyInputFormatter.formatCurrency(sale.total),
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const Gap(AppSpacing.space4),
            Row(
              children: [
                Icon(
                  AppIcons.shoppingBag,
                  size: AppSpacing.icon16,
                  color: context.colorScheme.onSurfaceVariant,
                ),
                const Gap(AppSpacing.space4),
                Expanded(
                  child: Text(
                    '$itemsCount ${itemsCount == 1 ? 'item' : 'itens'}: $itemsDescription',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  AppIcons.chevronRight,
                  size: AppSpacing.icon16,
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryFormView(ScrollController scrollController) {
    final sale = _selectedSale!;
    final itemsCount = sale.items.fold<int>(0, (sum, item) => sum + item.quantity);

    return SingleChildScrollView(
      controller: scrollController,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                if (widget.initialSale == null) ...[
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      setState(() => _selectedSale = null);
                    },
                  ),
                  const Gap(AppSpacing.space8),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nova Entrega',
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Venda #${sale.saleNumber}',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(AppIcons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Gap(AppSpacing.space12),

            // Resumo da venda selecionada
            Container(
              padding: const EdgeInsets.all(AppSpacing.space12),
              decoration: BoxDecoration(
                color: context.colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(AppSpacing.radius12),
                border: Border.all(
                  color: context.colorScheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sale.customerName?.isNotEmpty == true ? sale.customerName! : 'Cliente Avulso',
                          style: context.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Gap(2),
                        Text(
                          '$itemsCount ${itemsCount == 1 ? 'item' : 'itens'} • Total: ${CurrencyInputFormatter.formatCurrency(sale.total)}',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.initialSale == null)
                    TextButton(
                      onPressed: () => setState(() => _selectedSale = null),
                      child: const Text('Trocar'),
                    ),
                ],
              ),
            ),
            const Gap(AppSpacing.space16),

            Text(
              'Dados da Entrega',
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap(AppSpacing.space8),

            AppTextfield(
              controller: _addressController,
              label: 'Endereço de Entrega *',
              hint: 'Rua, número, bairro, complemento',
              prefixIcon: AppIcons.locationOn,
            ),
            const Gap(AppSpacing.space12),

            AppTextfield(
              controller: _phoneController,
              label: 'Telefone para Contato (opcional)',
              hint: '(00) 00000-0000',
              prefixIcon: AppIcons.phone,
              keyboardType: TextInputType.phone,
            ),
            const Gap(AppSpacing.space12),

            PaymentDeliveryScheduleCard(
              scheduledDate: _scheduledDate,
              onTap: _pickScheduleDate,
            ),
            const Gap(AppSpacing.space12),

            AppTextfield(
              controller: _notesController,
              label: 'Observações da entrega (opcional)',
              hint: 'Ponto de referência, instruções...',
              prefixIcon: AppIcons.editNote,
              maxLines: 2,
            ),
            const Gap(AppSpacing.space24),

            AppButton(
              label: 'Agendar Entrega',
              icon: AppIcons.truck,
              isLoading: _isLoading,
              onPressed: _submitDelivery,
            ),
            const Gap(AppSpacing.space8),
          ],
        ),
      ),
    );
  }
}
