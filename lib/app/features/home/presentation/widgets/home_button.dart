import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class HomeButton extends StatelessWidget {
  final String title;
  final String subTitle;
  final String? badgerContent;
  final Color? badgerColor;
  final Color color;
  final IconData? icon;
  final void Function()? onPressed;

  const HomeButton({
    super.key,
    required this.title,
    required this.subTitle,
    this.badgerContent,
    this.badgerColor,
    required this.color,
    this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.space24),
        side: BorderSide(color: context.colorScheme.outline, width: 0.2),
      ),

      child: InkWell(
        borderRadius: AppSpacing.borderRadius24,
        overlayColor: WidgetStateProperty.all(color.withValues(alpha: 0.1)),
        onTap: onPressed,
        child: Badge(
          label: Text(
            '$badgerContent',
            style: context.textTheme.bodySmall?.copyWith(color: AppColors.white, fontWeight: FontWeight.w800),
          ),
          backgroundColor: badgerColor,
          padding: EdgeInsets.all(AppSpacing.space4),
          isLabelVisible: badgerContent != null,
          offset: Offset(-24, AppSpacing.space20),
          child: Padding(
            padding: const .all(AppSpacing.space16),
            child: Column(
              mainAxisAlignment: .spaceBetween,
              crossAxisAlignment: .start,
              children: [
                Container(
                  padding: const .all(AppSpacing.space12),
                  decoration: BoxDecoration(
                    color: context.colorScheme.primary,
                    borderRadius: BorderRadius.circular(AppSpacing.space16),
                    gradient: LinearGradient(
                      colors: [
                        color.withValues(alpha: 0.8),
                        Color.lerp(color, Colors.black, 0.1)!,
                      ],
                      end: AlignmentGeometry.bottomEnd,
                    ),
                  ),

                  child: Icon(
                    icon,
                    color: AppColors.white,
                    size: AppSpacing.icon28,
                    weight: 600,
                  ),
                ),
                Column(
                  crossAxisAlignment: .start,
                  children: [
                    Text(title, style: context.textTheme.titleLarge /* ?.copyWith(height: 0.9) */),
                    Text(subTitle, style: context.textTheme.labelMedium),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
