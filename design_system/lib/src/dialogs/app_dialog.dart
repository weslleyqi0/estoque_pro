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
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          AppButton.text(
            label: cancelLabel,
            onPressed: () => Navigator.pop(context, false),
          ),
          isDestructive
              ? AppButton.text(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(
                    confirmLabel,
                    style: TextStyle(color: context.colorScheme.error, fontWeight: FontWeight.bold),
                  ),
                )
              : AppButton.text(
                  label: confirmLabel,
                  onPressed: () => Navigator.pop(context, true),
                ),
        ],
      ),
    );
  }
}
