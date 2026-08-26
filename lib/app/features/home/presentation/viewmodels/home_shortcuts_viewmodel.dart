import 'package:estoque_pro/app/core/services/local_storage_service.dart';
import 'package:estoque_pro/app/features/home/domain/entities/home_shortcut_type.dart';
import 'package:flutter/foundation.dart';

class HomeShortcutsViewModel extends ChangeNotifier {
  static const String _storageKey = 'home_shortcuts_order';

  final LocalStorageService _localStorageService;
  List<HomeShortcutType> _shortcuts = [];

  List<HomeShortcutType> get shortcuts => List.unmodifiable(_shortcuts);

  HomeShortcutsViewModel(this._localStorageService) {
    _loadOrder();
  }

  void _loadOrder() {
    final saved = _localStorageService.getString(_storageKey);
    if (saved != null && saved.trim().isNotEmpty) {
      final ids = saved.split(',').map((e) => e.trim()).toList();
      final loaded = <HomeShortcutType>[];
      for (final id in ids) {
        final type = HomeShortcutType.fromId(id);
        if (type != null && !loaded.contains(type)) {
          loaded.add(type);
        }
      }
      // Adiciona quaisquer novos atalhos que não estavam no storage antigo
      for (final def in HomeShortcutType.defaultOrder) {
        if (!loaded.contains(def)) {
          loaded.add(def);
        }
      }
      _shortcuts = loaded;
    } else {
      _shortcuts = List.from(HomeShortcutType.defaultOrder);
    }
  }

  List<HomeShortcutType> getShortcutsForRole({required bool isManager}) {
    if (isManager) {
      return _shortcuts;
    }
    return _shortcuts.where((s) => !s.managerOnly).toList();
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    final item = _shortcuts.removeAt(oldIndex);
    _shortcuts.insert(newIndex, item);
    notifyListeners();
    await _saveOrder();
  }

  Future<void> resetToDefault() async {
    _shortcuts = List.from(HomeShortcutType.defaultOrder);
    notifyListeners();
    await _localStorageService.remove(_storageKey);
  }

  Future<void> _saveOrder() async {
    final str = _shortcuts.map((e) => e.id).join(',');
    await _localStorageService.setString(_storageKey, str);
  }
}
