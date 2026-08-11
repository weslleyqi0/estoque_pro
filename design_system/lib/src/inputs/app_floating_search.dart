import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Design System Floating Search Sliver
class AppFloatingSearch extends StatefulWidget {
  final String hint;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final Widget? trailing;

  const AppFloatingSearch({
    super.key,
    this.hint = 'Pesquisar...',
    this.initialValue,
    this.onChanged,
    this.trailing,
  });

  @override
  State<AppFloatingSearch> createState() => _AppFloatingSearchState();
}

class _AppFloatingSearchState extends State<AppFloatingSearch> {
  late final TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _hasText = _controller.text.isNotEmpty;
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
      title: Row(
        children: [
          Expanded(
            child: AppTextfield(
              controller: _controller,
              hint: widget.hint,
              prefixIcon: AppIcons.search,
              suffixIcon: _hasText ? AppIcons.close : null,
              onSuffixIconPressed: _hasText ? _clearSearch : null,
              filled: true,
              filledColor: context.colorScheme.surface,
              onChanged: widget.onChanged,
            ),
          ),
          if (widget.trailing != null) ...[
            const Gap(AppSpacing.space8),
            widget.trailing!,
          ],
        ],
      ),
    );
  }
}
