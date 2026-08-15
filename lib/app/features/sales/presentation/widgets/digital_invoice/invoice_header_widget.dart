import 'dart:ui' as ui;
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class InvoiceHeaderWidget extends StatelessWidget {
  const InvoiceHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
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
              fontWeight: .w900,
              letterSpacing: 1.0,
            ),
          ),
          const Gap(2),
          Text(
            'COMPROVANTE DE VENDA',
            style: context.textTheme.labelMedium?.copyWith(
              fontWeight: .bold,
              letterSpacing: 1.2,
            ),
          ),
          Text(
            'Documento Informativo (Não Fiscal)',
            style: context.textTheme.labelSmall?.copyWith(
              color: context.colorScheme.error,
              fontStyle: .italic,
              fontWeight: ui.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
