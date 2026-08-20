import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

abstract class CategoryIcons {
  static Map<String, IconData> get icons => AppIcons.categoryIcons;
  static IconData getIcon(String key) => AppIcons.getCategoryIcon(key);
}
