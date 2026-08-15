import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class InvoiceInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isBold;

  const InvoiceInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const .symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: .spaceBetween,
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
                fontWeight: isBold ? .bold : .normal,
                color: valueColor ?? context.colorScheme.onSurface,
              ),
              textAlign: .right,
              overflow: .ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
