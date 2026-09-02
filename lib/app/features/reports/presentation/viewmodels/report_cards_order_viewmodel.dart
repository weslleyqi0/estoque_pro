import 'package:estoque_pro/app/core/base/base_viewmodel.dart';
import 'package:estoque_pro/app/core/services/local_storage_service.dart';
import 'package:estoque_pro/app/features/reports/domain/entities/report_card_type.dart';

class ReportCardsOrderViewModel extends BaseViewModel {
  static const String _storageKey = 'report_cards_order';
  static const String _hiddenKey = 'report_cards_hidden';

  final LocalStorageService _localStorageService;
  List<ReportCardType> _cards = [];
  Set<String> _hiddenCardIds = {};

  List<ReportCardType> get cards => List.unmodifiable(_cards);

  List<ReportCardType> get visibleCards =>
      List.unmodifiable(_cards.where((c) => !_hiddenCardIds.contains(c.id)));

  bool isCardVisible(ReportCardType card) => !_hiddenCardIds.contains(card.id);

  ReportCardsOrderViewModel(this._localStorageService) {
    _loadOrderAndVisibility();
  }

  void _loadOrderAndVisibility() {
    // 1. Carregar ordem
    final savedOrder = _localStorageService.getString(_storageKey);
    if (savedOrder != null && savedOrder.trim().isNotEmpty) {
      final ids = savedOrder.split(',').map((e) => e.trim()).toList();
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

    // 2. Carregar cards ocultos
    final savedHidden = _localStorageService.getString(_hiddenKey);
    if (savedHidden != null && savedHidden.trim().isNotEmpty) {
      _hiddenCardIds = savedHidden
          .split(',')
          .map((e) => e.trim())
          .where((id) => id.isNotEmpty)
          .toSet();
    } else {
      _hiddenCardIds = {};
    }
  }

  Future<void> toggleCardVisibility(ReportCardType card) async {
    if (_hiddenCardIds.contains(card.id)) {
      _hiddenCardIds.remove(card.id);
    } else {
      _hiddenCardIds.add(card.id);
    }
    notifyListeners();
    await _saveHidden();
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    final item = _cards.removeAt(oldIndex);
    _cards.insert(newIndex, item);
    notifyListeners();
    await _saveOrder();
  }

  Future<void> resetToDefault() async {
    _cards = List.from(ReportCardType.defaultOrder);
    _hiddenCardIds.clear();
    notifyListeners();
    await _localStorageService.remove(_storageKey);
    await _localStorageService.remove(_hiddenKey);
  }

  Future<void> _saveOrder() async {
    final str = _cards.map((e) => e.id).join(',');
    await _localStorageService.setString(_storageKey, str);
  }

  Future<void> _saveHidden() async {
    if (_hiddenCardIds.isEmpty) {
      await _localStorageService.remove(_hiddenKey);
    } else {
      final str = _hiddenCardIds.join(',');
      await _localStorageService.setString(_hiddenKey, str);
    }
  }
}
