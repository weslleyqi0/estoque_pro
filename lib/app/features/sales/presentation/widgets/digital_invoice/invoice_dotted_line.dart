import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class InvoiceDottedLine extends StatelessWidget {
  const InvoiceDottedLine({super.key});

  @override
  Widget build(BuildContext context) {
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
}
