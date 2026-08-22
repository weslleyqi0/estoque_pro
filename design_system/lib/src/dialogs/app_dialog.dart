import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class AppDialog {
  AppDialog._();

  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool barrierDismissible = true,
    Color? barrierColor = Colors.black54,
    String? barrierLabel,
    bool useSafeArea = true,
    bool useRootNavigator = true,
  }) {
    return showDialog<T>(
      context: context,
      builder: builder,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      barrierLabel: barrierLabel,
      useSafeArea: useSafeArea,
      useRootNavigator: useRootNavigator,
    );
  }

  static Future<bool?> showConfirmation({
    required BuildContext context,
    required String title,
    required String content,
    String confirmLabel = 'Confirmar',
    String cancelLabel = 'Cancelar',
    Color? confirmColor,
    Color? cancelColor,
    bool isDestructive = false,
  }) {
    return show<bool>(
      context: context,
      builder: (context) {
        final effectiveConfirmColor = confirmColor ?? (isDestructive ? context.colorScheme.error : null);

        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            SizedBox(
              height: AppSpacing.space40,
              child: AppButton.text(
                onPressed: () => Navigator.pop(context, false),
                label: cancelLabel,
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.space8),
                textStyle: cancelColor != null
                    ? context.textTheme.bodyLarge?.copyWith(color: cancelColor, fontWeight: FontWeight.bold)
                    : context.textTheme.bodyLarge,
              ),
            ),
            SizedBox(
              height: AppSpacing.space40,
              child: AppButton.text(
                onPressed: () => Navigator.pop(context, true),
                label: confirmLabel,
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.space8),
                textStyle: effectiveConfirmColor != null
                    ? context.textTheme.bodyLarge?.copyWith(color: effectiveConfirmColor, fontWeight: .bold)
                    : context.textTheme.bodyLarge?.copyWith(color: context.colorScheme.primary, fontWeight: .bold),
              ),
            ),
          ],
        );
      },
    );
  }
}
