import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Design System Floating Search Sliver
class AppFloatingSearch extends StatelessWidget {
  final String hint;
  final ValueChanged<String>? onChanged;

  const AppFloatingSearch({
    super.key,
    this.hint = 'Pesquisar...',
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      floating: true,
      snap: true,
      automaticallyImplyLeading: false,
      toolbarHeight: 90,
      backgroundColor: AppColors.transparent,
      scrolledUnderElevation: 0,
      title: AppTextfield(
        hint: hint,
        prefixIcon: Symbols.search_rounded,
        filled: true,
        filledColor: context.colorScheme.surface,
        onChanged: onChanged,
      ),
    );
  }
}
