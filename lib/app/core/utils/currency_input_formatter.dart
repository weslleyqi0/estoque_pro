import 'package:flutter/services.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  final bool includeSymbol;

  CurrencyInputFormatter({this.includeSymbol = true});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    final value = double.parse(digitsOnly) / 100;
    final formatted = formatDouble(value);
    final newString = includeSymbol ? 'R\$ $formatted' : formatted;

    return TextEditingValue(
      text: newString,
      selection: TextSelection.collapsed(offset: newString.length),
    );
  }

  static String formatDouble(double value) {
    final newString = value.toStringAsFixed(2).replaceAll('.', ',');
    return formatString(newString);
  }

  static String formatCurrency(double value) {
    return 'R\$ ${formatDouble(value)}';
  }

  static String formatString(String value) {
    final parts = value.split(',');
    final intPart = parts[0];
    final decPart = parts.length > 1 ? parts[1] : '00';

    var newIntPart = '';
    var count = 0;
    for (var i = intPart.length - 1; i >= 0; i--) {
      newIntPart = intPart[i] + newIntPart;
      count++;
      if (count % 3 == 0 && i != 0) {
        newIntPart = '.$newIntPart';
      }
    }
    return '$newIntPart,$decPart';
  }
}
