import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/features/categories/domain/entities/category_entity.dart';
import 'package:estoque_pro/app/features/categories/presentation/utils/category_icons.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class CategorySelectionItem extends StatelessWidget {
  final CategoryEntity category;
  final VoidCallback onTap;
  final bool isSelected;

  const CategorySelectionItem({
    super.key,
    required this.category,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final categoryColor = category.color != null ? Color(category.color!) : context.colorScheme.primary;
    final iconColor = categoryColor;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: InkWell(
        onTap: onTap,
        overlayColor: WidgetStateProperty.all(context.colorScheme.primary.withValues(alpha: 0.1)),
        borderRadius: AppSpacing.borderRadius12,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.space8),
          decoration: BoxDecoration(
            color: isSelected ? context.colorScheme.primary.withValues(alpha: 0.2) : null,
            borderRadius: AppSpacing.borderRadius12,
            border: Border.all(
              color: isSelected ? context.colorScheme.primary.withValues(alpha: 0.2) : context.colorScheme.outline,
              width: isSelected ? 1 : 0.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.space8),
                decoration: BoxDecoration(
                  borderRadius: AppSpacing.borderRadius8,
                  color: iconColor.withValues(alpha: 0.1),
                ),
                child: Icon(
                  CategoryIcons.getIcon(category.icon),
                  color: iconColor,
                  size: AppSpacing.icon20,
                  weight: 600,
                ),
              ),
              const Gap(AppSpacing.space12),
              Expanded(
                child: Text(
                  category.name,
                  style: context.textTheme.titleMedium,
                ),
              ),
              Checkbox(
                value: isSelected,
                onChanged: (_) => onTap(),
                shape: const RoundedRectangleBorder(borderRadius: AppSpacing.borderRadius4),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
