import 'package:estoque_pro/app/core/services/local_storage_service.dart';
import 'package:flutter/material.dart';

class ThemeViewModel extends ChangeNotifier {
  static const String _themeModeKey = 'app_theme_mode';

  final LocalStorageService _localStorageService;
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  ThemeViewModel(this._localStorageService) {
    final savedMode = _localStorageService.getString(_themeModeKey);
    if (savedMode != null) {
      _themeMode = switch (savedMode) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    await _localStorageService.setString(_themeModeKey, mode.name);
    notifyListeners();
  }
}
