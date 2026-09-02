import 'package:estoque_pro/app/core/base/base_viewmodel.dart';
import 'package:estoque_pro/app/core/services/local_storage_service.dart';
import 'package:estoque_pro/app/features/reports/domain/entities/report_card_type.dart';

class ReportCardsOrderViewModel extends BaseViewModel {
  static const String _storageKey = 'report_cards_order';

  final LocalStorageService _localStorageService;
  List<ReportCardType> _cards = [];

  List<ReportCardType> get cards => List.unmodifiable(_cards);

  ReportCardsOrderViewModel(this._localStorageService) {
    _loadOrder();
  }

  void _loadOrder() {
    final saved = _localStorageService.getString(_storageKey);
    if (saved != null && saved.trim().isNotEmpty) {
      final ids = saved.split(',').map((e) => e.trim()).toList();
      final loaded = <ReportCardType>[];
      for (final id in ids) {
        final type = ReportCardType.fromId(id);
        if (type != null && !loaded.contains(type)) {
          loaded.add(type);
        }
      }
      // Adiciona quaisquer novos cards que não estavam no storage antigo
      for (final def in ReportCardType.defaultOrder) {
        if (!loaded.contains(def)) {
          loaded.add(def);
        }
      }
      _cards = loaded;
    } else {
      _cards = List.from(ReportCardType.defaultOrder);
    }
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    final item = _cards.removeAt(oldIndex);
    _cards.insert(newIndex, item);
    notifyListeners();
    await _saveOrder();
  }

  Future<void> resetToDefault() async {
    _cards = List.from(ReportCardType.defaultOrder);
    notifyListeners();
    await _localStorageService.remove(_storageKey);
  }

  Future<void> _saveOrder() async {
    final str = _cards.map((e) => e.id).join(',');
    await _localStorageService.setString(_storageKey, str);
  }
}
