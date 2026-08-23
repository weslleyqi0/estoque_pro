extension ListSortingExtension<T> on Iterable<T> {
  /// Retorna uma nova lista ordenada por texto em ordem alfabética (case-insensitive).
  List<T> sortedByName(String Function(T item) keySelector, {bool ascending = true}) {
    final list = List<T>.from(this);
    list.sort((a, b) {
      final textA = keySelector(a).toLowerCase();
      final textB = keySelector(b).toLowerCase();
      return ascending ? textA.compareTo(textB) : textB.compareTo(textA);
    });
    return list;
  }
}

extension MutableListSortingExtension<T> on List<T> {
  /// Ordena a lista in-place por texto em ordem alfabética (case-insensitive) e a retorna.
  List<T> sortByName(String Function(T item) keySelector, {bool ascending = true}) {
    sort((a, b) {
      final textA = keySelector(a).toLowerCase();
      final textB = keySelector(b).toLowerCase();
      return ascending ? textA.compareTo(textB) : textB.compareTo(textA);
    });
    return this;
  }
}
