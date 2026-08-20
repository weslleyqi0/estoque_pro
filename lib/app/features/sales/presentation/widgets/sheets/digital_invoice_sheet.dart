import 'dart:io';
import 'dart:ui' as ui;

import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_entity.dart';
import 'package:estoque_pro/app/features/sales/presentation/widgets/digital_invoice/invoice_details_section.dart';
import 'package:estoque_pro/app/features/sales/presentation/widgets/digital_invoice/invoice_dotted_line.dart';
import 'package:estoque_pro/app/features/sales/presentation/widgets/digital_invoice/invoice_financial_summary.dart';
import 'package:estoque_pro/app/features/sales/presentation/widgets/digital_invoice/invoice_header_widget.dart';
import 'package:estoque_pro/app/features/sales/presentation/widgets/digital_invoice/invoice_items_list_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gap/gap.dart';
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

  @override
  Widget build(BuildContext context) {
    final sale = widget.sale;

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
                AppIconButton(
                  icon: AppIcons.close,
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
                      const InvoiceHeaderWidget(),
                      const Gap(AppSpacing.space16),
                      const InvoiceDottedLine(),
                      const Gap(AppSpacing.space16),
                      InvoiceDetailsSection(sale: sale),
                      const Gap(AppSpacing.space16),
                      const InvoiceDottedLine(),
                      const Gap(AppSpacing.space16),
                      InvoiceItemsListSection(sale: sale),
                      const Gap(AppSpacing.space16),
                      const InvoiceDottedLine(),
                      const Gap(AppSpacing.space16),
                      InvoiceFinancialSummary(sale: sale),
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
}
