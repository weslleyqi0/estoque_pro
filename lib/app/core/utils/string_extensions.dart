extension StringNumberParsing on String {
  int toIntOr([int defaultValue = 0]) {
    return int.tryParse(this) ?? defaultValue;
  }

  double toDoubleOr([double defaultValue = 0.0]) {
    final normalized = replaceAll('.', '').replaceAll(',', '.');
    return double.tryParse(normalized) ?? defaultValue;
  }
}
