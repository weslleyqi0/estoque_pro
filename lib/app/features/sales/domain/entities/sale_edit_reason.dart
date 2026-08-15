enum SaleEditReason {
  addition('addition', 'Adição'),
  returnItem('return', 'Devolução'),
  exchange('exchange', 'Troca'),
  correction('correction', 'Correção'),
  removal('removal', 'Remoção');

  final String value;
  final String label;

  const SaleEditReason(this.value, this.label);

  static SaleEditReason? fromValue(String? value) {
    for (final reason in values) {
      if (reason.value == value || reason.label == value || reason.name == value) return reason;
    }
    return null;
  }
}
