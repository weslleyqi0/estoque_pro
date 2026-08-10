enum DiscountType {
  percent('percent', 'Percentual (%)'),
  valueAmount('value', 'Valor (R\$)');

  final String rawValue;
  final String label;

  const DiscountType(this.rawValue, this.label);

  static DiscountType fromValue(String? val) {
    for (final type in values) {
      if (type.rawValue == val) return type;
    }
    return DiscountType.valueAmount;
  }
}
