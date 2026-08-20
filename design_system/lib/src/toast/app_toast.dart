import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../theme/app_colors.dart';

export 'package:fluttertoast/fluttertoast.dart' show Toast, ToastGravity;

enum AppToastType { success, error, warning, info }

class AppToast {
  AppToast._();

  static (Color backgroundColor, Color textColor) _getColorsByType(AppToastType type) {
    switch (type) {
      case AppToastType.success:
        return (AppColors.successDark, AppColors.white);
      case AppToastType.error:
        return (AppColors.errorDark, AppColors.white);
      case AppToastType.warning:
        return (AppColors.warningDark, AppColors.white);
      case AppToastType.info:
        return (AppColors.infoDark, AppColors.white);
    }
  }

  static Future<bool?> show({
    required String msg,
    AppToastType type = AppToastType.info,
    Toast? toastLength = Toast.LENGTH_LONG,
    ToastGravity? gravity = ToastGravity.BOTTOM,
    int timeInSecForIosWeb = 3,
    Color? backgroundColor,
    Color? textColor,
    double fontSize = 14.0,
  }) {
    final (defaultBgColor, defaultTextColor) = _getColorsByType(type);

    return Fluttertoast.showToast(
      msg: msg,
      toastLength: toastLength,
      gravity: gravity,
      timeInSecForIosWeb: timeInSecForIosWeb,
      backgroundColor: backgroundColor ?? defaultBgColor,
      textColor: textColor ?? defaultTextColor,
      fontSize: fontSize,
    );
  }

  static Future<bool?> success(
    String msg, {
    Toast? toastLength = Toast.LENGTH_LONG,
    ToastGravity? gravity = ToastGravity.BOTTOM,
    int timeInSecForIosWeb = 3,
    double fontSize = 14.0,
  }) {
    return show(
      msg: msg,
      type: AppToastType.success,
      toastLength: toastLength,
      gravity: gravity,
      timeInSecForIosWeb: timeInSecForIosWeb,
      fontSize: fontSize,
    );
  }

  static Future<bool?> error(
    String msg, {
    Toast? toastLength = Toast.LENGTH_LONG,
    ToastGravity? gravity = ToastGravity.BOTTOM,
    int timeInSecForIosWeb = 3,
    double fontSize = 14.0,
  }) {
    return show(
      msg: msg,
      type: AppToastType.error,
      toastLength: toastLength,
      gravity: gravity,
      timeInSecForIosWeb: timeInSecForIosWeb,
      fontSize: fontSize,
    );
  }

  static Future<bool?> warning(
    String msg, {
    Toast? toastLength = Toast.LENGTH_LONG,
    ToastGravity? gravity = ToastGravity.BOTTOM,
    int timeInSecForIosWeb = 3,
    double fontSize = 14.0,
  }) {
    return show(
      msg: msg,
      type: AppToastType.warning,
      toastLength: toastLength,
      gravity: gravity,
      timeInSecForIosWeb: timeInSecForIosWeb,
      fontSize: fontSize,
    );
  }

  static Future<bool?> info(
    String msg, {
    Toast? toastLength = Toast.LENGTH_LONG,
    ToastGravity? gravity = ToastGravity.BOTTOM,
    int timeInSecForIosWeb = 3,
    double fontSize = 14.0,
  }) {
    return show(
      msg: msg,
      type: AppToastType.info,
      toastLength: toastLength,
      gravity: gravity,
      timeInSecForIosWeb: timeInSecForIosWeb,
      fontSize: fontSize,
    );
  }

  static Future<bool?> cancel() {
    return Fluttertoast.cancel();
  }
}
