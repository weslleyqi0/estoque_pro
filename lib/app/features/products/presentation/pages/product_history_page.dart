import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_entity.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_history_entity.dart';
import 'package:estoque_pro/app/features/products/presentation/widgets/product_history_card.dart';
import 'package:flutter/material.dart';

class ProductHistoryPage extends StatefulWidget {
  final ProductEntity product;

  const ProductHistoryPage({super.key, required this.product});

  @override
  State<ProductHistoryPage> createState() => _ProductHistoryPageState();
}

class _ProductHistoryPageState extends State<ProductHistoryPage> {
  final ScrollController _scrollController = ScrollController();

  late final List<ProductHistoryEntity> _fullHistory;
  int _itemsToShow = 20;

  @override
  void initState() {
    super.initState();
    // Ordena por data decrescente
    _fullHistory = List.from(widget.product.history)..sort((a, b) => b.date.compareTo(a.date));

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (_itemsToShow < _fullHistory.length) {
        setState(() {
          _itemsToShow += 20;
          if (_itemsToShow > _fullHistory.length) {
            _itemsToShow = _fullHistory.length;
          }
        });
      }
    }
  }

  String _formatDate(DateTime date) {
    final weekdays = [
      'Segunda-feira',
      'Terça-feira',
      'Quarta-feira',
      'Quinta-feira',
      'Sexta-feira',
      'Sábado',
      'Domingo',
    ];
    final months = [
      'janeiro',
      'fevereiro',
      'março',
      'abril',
      'maio',
      'junho',
      'julho',
      'agosto',
      'setembro',
      'outubro',
      'novembro',
      'dezembro',
    ];

    final wd = weekdays[date.weekday - 1];
    final m = months[date.month - 1];
    return '$wd, ${date.day} de $m';
  }

  @override
  Widget build(BuildContext context) {
    if (_fullHistory.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Histórico Completo')),
        body: const Center(child: Text('Nenhuma movimentação registrada.')),
      );
    }

    final displayedHistory = _fullHistory.take(_itemsToShow).toList();

    final grouped = <String, List<ProductHistoryEntity>>{};
    for (final h in displayedHistory) {
      final key = _formatDate(h.date);
      if (grouped[key] == null) grouped[key] = [];
      grouped[key]!.add(h);
    }
    final keys = grouped.keys.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico Completo'),
      ),
      body: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(AppSpacing.space16),
        itemCount: keys.length + (_itemsToShow < _fullHistory.length ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == keys.length) {
            return const Padding(
              padding: EdgeInsets.all(AppSpacing.space16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final dayKey = keys[index];
          final items = grouped[dayKey]!;

          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.space16),
            child: ProductHistoryCard(
              title: dayKey,
              subtitle: '${items.length} movimentaç${items.length == 1 ? 'ão' : 'ões'}',
              history: items,
              onViewAll: null,
            ),
          );
        },
      ),
    );
  }
}
