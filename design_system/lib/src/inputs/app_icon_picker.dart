import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class AppIconPicker extends StatelessWidget {
  final Map<String, IconData> icons;
  final String selectedIcon;
  final ValueChanged<String> onIconSelected;

  const AppIconPicker({
    super.key,
    required this.icons,
    required this.selectedIcon,
    required this.onIconSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        crossAxisSpacing: AppSpacing.space8,
        mainAxisSpacing: AppSpacing.space8,
      ),
      itemCount: icons.length,
      itemBuilder: (context, index) {
        final key = icons.keys.elementAt(index);
        final icon = icons[key]!;
        final isSelected = selectedIcon == key;

        return InkWell(
          onTap: () => onIconSelected(key),
          borderRadius: AppSpacing.borderRadius12,
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? context.colorScheme.primary : context.colorScheme.surface,
              border: Border.all(
                color: isSelected ? context.colorScheme.primary : context.colorScheme.outline,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: AppSpacing.borderRadius16,
            ),
            child: Icon(
              icon,
              color: isSelected ? AppColors.white : context.colorScheme.onSurface,
              weight: isSelected ? 600 : 400,
            ),
          ),
        );
      },
    );
  }
}
