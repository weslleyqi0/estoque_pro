import 'dart:io';
import 'dart:ui' as ui;
import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/core/utils/currency_input_formatter.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/payment_method.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class DigitalInvoiceSheet extends StatefulWidget {
  final SaleEntity sale;

  const DigitalInvoiceSheet({
    super.key,
    required this.sale,
  });

  static Future<void> show(BuildContext context, SaleEntity sale) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DigitalInvoiceSheet(sale: sale),
    );
  }

  @override
  State<DigitalInvoiceSheet> createState() => _DigitalInvoiceSheetState();
}

class _DigitalInvoiceSheetState extends State<DigitalInvoiceSheet> {
  final GlobalKey _repaintKey = GlobalKey();
  bool _isSharing = false;

  Future<void> _shareAsImage() async {
    if (_isSharing) return;

    setState(() {
      _isSharing = true;
    });

    try {
      final boundary = _repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        if (mounted) {
          AppToast.error(
            'Erro ao localizar a imagem da nota.',
            toastLength: Toast.LENGTH_SHORT,
          );
        }
        return;
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        if (mounted) {
          AppToast.error(
            'Erro ao gerar a imagem da nota.',
            toastLength: Toast.LENGTH_SHORT,
          );
        }
        return;
      }

      final bytes = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final cleanSaleNum = widget.sale.saleNumber.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
      final file = File('${tempDir.path}/comprovante_$cleanSaleNum.png');
      await file.writeAsBytes(bytes);

      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'image/png')],
        text: 'Comprovante de Venda ${widget.sale.saleNumber} - EstoquePro',
      );
    } catch (e) {
      if (mounted) {
        AppToast.error(
          'Erro ao compartilhar imagem da nota.',
          toastLength: Toast.LENGTH_SHORT,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
      }
    }
  }

  IconData _getPaymentIcon(PaymentMethod method) {
    return switch (method) {
      PaymentMethod.dinheiro => Icons.payments_rounded,
      PaymentMethod.pix => Icons.qr_code_rounded,
      PaymentMethod.credito => Icons.credit_card_rounded,
      PaymentMethod.debito => Icons.credit_card_rounded,
      PaymentMethod.fiado => Icons.bookmark_add_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    final sale = widget.sale;
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final amountPaid = sale.amountPaid ?? 0.0;
    final change = (sale.change ?? 0.0).clamp(0.0, double.infinity);

    return Container(
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSpacing.radius24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Gap(AppSpacing.space8),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Gap(AppSpacing.space8),

          // Header Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.space8),
                      decoration: BoxDecoration(
                        color: context.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(AppSpacing.radius12),
                      ),
                      child: Icon(
                        Icons.receipt_long_rounded,
                        color: context.colorScheme.surface,
                        size: AppSpacing.icon24,
                      ),
                    ),
                    const Gap(AppSpacing.space12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Comprovante de Venda',
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Venda ${sale.saleNumber}',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(AppIcons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Receipt Body wrapped in RepaintBoundary for image capture
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.space16),
              child: RepaintBoundary(
                key: _repaintKey,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.space20),
                  decoration: BoxDecoration(
                    color: context.colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(AppSpacing.radius16),
                    border: Border.all(
                      color: context.colorScheme.outlineVariant,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Store Title
                      Center(
                        child: Column(
                          children: [
                            Icon(
                              AppIcons.inventory2,
                              size: AppSpacing.icon32,
                              color: context.colorScheme.primary,
                            ),
                            const Gap(AppSpacing.space4),
                            Text(
                              'ESTOQUE PRO',
                              style: context.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const Gap(2),
                            Text(
                              'COMPROVANTE DE VENDA',
                              style: context.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                            Text(
                              'Documento Informativo (Não Fiscal)',
                              style: context.textTheme.labelSmall?.copyWith(
                                color: context.colorScheme.error,
                                fontStyle: FontStyle.italic,
                                fontWeight: ui.FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Gap(AppSpacing.space16),
                      _buildDottedLine(context),
                      const Gap(AppSpacing.space16),

                      // Purchase Details (Data, Vendedor, Cliente, Pagamento, Status)
                      _buildInfoRow(context, 'Nº da Venda:', sale.saleNumber, isBold: true),
                      _buildInfoRow(context, 'Data & Hora:', dateFormat.format(sale.createdAt)),
                      _buildInfoRow(context, 'Vendedor:', sale.userName),
                      _buildInfoRow(
                        context,
                        'Cliente:',
                        sale.customerName?.isNotEmpty == true ? sale.customerName! : 'Não informado',
                      ),

                      // Payment Row with Icon
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Forma de Pagamento:',
                              style: context.textTheme.bodySmall?.copyWith(
                                color: context.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getPaymentIcon(sale.paymentMethod),
                                  size: AppSpacing.icon16,
                                  color: context.colorScheme.primary,
                                ),
                                const Gap(4),
                                Text(
                                  sale.paymentMethod.label,
                                  style: context.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: context.colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Cash Specific Details (Valor Recebido & Troco)
                      if (sale.paymentMethod == PaymentMethod.dinheiro && amountPaid > 0) ...[
                        _buildInfoRow(
                          context,
                          'Valor Recebido:',
                          CurrencyInputFormatter.formatCurrency(amountPaid),
                        ),
                        _buildInfoRow(
                          context,
                          'Troco:',
                          CurrencyInputFormatter.formatCurrency(change),
                          valueColor: AppColors.success,
                          isBold: true,
                        ),
                      ],

                      _buildInfoRow(
                        context,
                        'Status:',
                        sale.status.label,
                        valueColor: sale.status == SaleStatus.completed
                            ? AppColors.success
                            : sale.status == SaleStatus.cancelled
                            ? AppColors.error
                            : AppColors.warning,
                        isBold: true,
                      ),

                      const Gap(AppSpacing.space16),
                      _buildDottedLine(context),
                      const Gap(AppSpacing.space16),

                      // Items Section Title
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'ITENS DA COMPRA',
                            style: context.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: context.colorScheme.primary,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            '${sale.totalItems} ${sale.totalItems == 1 ? 'item' : 'itens'}',
                            style: context.textTheme.labelLarge,
                          ),
                        ],
                      ),
                      const Gap(AppSpacing.space8),

                      // Items List
                      ...List.generate(sale.items.length, (index) {
                        final item = sale.items[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.productName,
                                      style: context.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '${item.quantity} x ${CurrencyInputFormatter.formatCurrency(item.unitPrice)}',
                                      style: context.textTheme.labelLarge?.copyWith(
                                        color: context.colorScheme.onSurface.withValues(alpha: 0.5),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Gap(AppSpacing.space8),
                              Text(
                                CurrencyInputFormatter.formatCurrency(item.totalPrice),
                                style: context.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),

                      const Gap(AppSpacing.space16),
                      _buildDottedLine(context),
                      const Gap(AppSpacing.space16),

                      // Financial Summary
                      _buildInfoRow(context, 'Qtd. Total de Itens:', '${sale.totalItems}'),
                      _buildInfoRow(
                        context,
                        'Subtotal:',
                        CurrencyInputFormatter.formatCurrency(sale.subtotal),
                      ),
                      if (sale.discountValue > 0)
                        _buildInfoRow(
                          context,
                          'Desconto:',
                          '- ${CurrencyInputFormatter.formatCurrency(sale.discountValue)}',
                          valueColor: AppColors.error,
                          isBold: true,
                        ),
                      const Gap(AppSpacing.space8),

                      // Highlighted Total
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.space12),
                        decoration: BoxDecoration(
                          color: context.colorScheme.outline.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(AppSpacing.radius12),
                          border: Border.all(color: context.colorScheme.outline),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'TOTAL DA VENDA',
                              style: context.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              CurrencyInputFormatter.formatCurrency(sale.total),
                              style: context.textTheme.headlineSmall?.copyWith(
                                color: context.colorScheme.primary,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Gap(AppSpacing.space20),
                      Center(
                        child: Text(
                          'Obrigado pela preferência!',
                          style: context.textTheme.bodyMedium?.copyWith(
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Action Button Footer
          Padding(
            padding: const EdgeInsets.all(AppSpacing.space16),
            child: AppButton(
              onPressed: _isSharing ? null : _shareAsImage,
              icon: Icons.share_rounded,
              isFullWidth: true,
              label: _isSharing ? 'Gerando Imagem...' : 'Compartilhar Imagem da Nota',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDottedLine(BuildContext context) {
    return Row(
      children: List.generate(
        40,
        (index) => Expanded(
          child: Container(
            color: index % 2 == 0 ? context.colorScheme.outline : Colors.transparent,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value, {
    Color? valueColor,
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: context.textTheme.bodySmall?.copyWith(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: valueColor ?? context.colorScheme.onSurface,
              ),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
