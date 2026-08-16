extension StringNumberParsing on String {
  int toIntOr([int defaultValue = 0]) {
    return int.tryParse(this) ?? defaultValue;
  }

  double toDoubleOr([double defaultValue = 0.0]) {
    final digits = replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return defaultValue;
    return (double.tryParse(digits) ?? 0.0) / 100;
  }

  String get withoutDiacritics {
    var withDia = 'ÀÁÂÃÄÅàáâãäåÒÓÔÕÕÖØòóôõöøÈÉÊËèéêëðÇçÐÌÍÎÏìíîïÙÚÛÜùúûüÑñŠšŸÿýŽž';
    var withoutDia = 'AAAAAAaaaaaaOOOOOOOooooooEEEEeeeeeCcDIIIIiiiiUUUUuuuuNnSsYyyZz';

    String str = this;
    for (int i = 0; i < withDia.length; i++) {
      str = str.replaceAll(withDia[i], withoutDia[i]);
    }
    return str;
  }

  String get normalizedBarcode {
    return replaceAll(RegExp(r'[\s-]'), '').toLowerCase();
  }
}
