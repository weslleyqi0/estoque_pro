import 'package:flutter/services.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (newText.isEmpty) newText = '0';
    double value = double.parse(newText) / 100;

    String newString = value.toStringAsFixed(2).replaceAll('.', ',');
    newString = formatString(newString);

    return newValue.copyWith(
      text: newString,
      selection: TextSelection.collapsed(offset: newString.length),
    );
  }

  static String formatDouble(double value) {
    String newString = value.toStringAsFixed(2).replaceAll('.', ',');
    return formatString(newString);
  }

  static String formatCurrency(double value) {
    return 'R\$ ${formatDouble(value)}';
  }

  static String formatString(String value) {
    List<String> parts = value.split(',');
    String intPart = parts[0];
    String decPart = parts.length > 1 ? parts[1] : '00';

    String newIntPart = '';
    int count = 0;
    for (int i = intPart.length - 1; i >= 0; i--) {
      newIntPart = intPart[i] + newIntPart;
      count++;
      if (count % 3 == 0 && i != 0) {
        newIntPart = '.$newIntPart';
      }
    }
    return '$newIntPart,$decPart';
  }
}
