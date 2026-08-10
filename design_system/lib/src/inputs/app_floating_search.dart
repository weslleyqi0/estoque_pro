import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Design System Floating Search Sliver
class AppFloatingSearch extends StatefulWidget {
  final String hint;
  final ValueChanged<String>? onChanged;

  const AppFloatingSearch({
    super.key,
    this.hint = 'Pesquisar...',
    this.onChanged,
  });

  @override
  State<AppFloatingSearch> createState() => _AppFloatingSearchState();
}

class _AppFloatingSearchState extends State<AppFloatingSearch> {
  final _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (_hasText != hasText) {
      setState(() => _hasText = hasText);
    }
  }

  void _clearSearch() {
    _controller.clear();
    widget.onChanged?.call('');
  }

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
        controller: _controller,
        hint: widget.hint,
        prefixIcon: AppIcons.search,
        suffixIcon: _hasText ? AppIcons.close : null,
        onSuffixIconPressed: _hasText ? _clearSearch : null,
        filled: true,
        filledColor: context.colorScheme.surface,
        onChanged: widget.onChanged,
      ),
    );
  }
}
