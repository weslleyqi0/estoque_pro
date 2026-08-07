import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/core/router/app_routes.dart';
import 'package:estoque_pro/app/features/categories/domain/entities/category_entity.dart';
import 'package:estoque_pro/app/features/categories/presentation/utils/category_icons.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

class CategoriesItem extends StatelessWidget {
  final CategoryEntity category;

  const CategoriesItem({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final categoryColor = category.color != null ? Color(category.color!) : context.colorScheme.primary;
    final iconColor = categoryColor;

    return Card(
      color: context.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.borderRadius16,
        side: BorderSide(color: context.colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: () => context.push(AppRoutes.categoryForm, extra: category),
        borderRadius: AppSpacing.borderRadius16,
        child: Padding(
          padding: const .all(AppSpacing.space12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.space12),
                decoration: BoxDecoration(
                  borderRadius: AppSpacing.borderRadius12,
                  color: iconColor.withValues(alpha: 0.1),
                ),
                child: Icon(
                  CategoryIcons.getIcon(category.icon),
                  color: iconColor,
                  size: AppSpacing.icon24,
                  weight: 600,
                ),
              ),
              const Gap(AppSpacing.space12),
              Column(
                crossAxisAlignment: .start,
                mainAxisSize: .min,
                children: [
                  Text(
                    category.name,
                    style: context.textTheme.titleMedium,
                  ),
                  AppTag(
                    title: '5 produtos',
                    icon: Symbols.package_2_rounded,
                    color: context.colorScheme.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
