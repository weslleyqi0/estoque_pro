extension StringNumberParsing on String {
  int toIntOr([int defaultValue = 0]) {
    return int.tryParse(this) ?? defaultValue;
  }

  double toDoubleOr([double defaultValue = 0.0]) {
    final normalized = replaceAll('.', '').replaceAll(',', '.');
    return double.tryParse(normalized) ?? defaultValue;
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
}
