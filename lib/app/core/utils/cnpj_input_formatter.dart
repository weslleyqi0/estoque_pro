import 'package:flutter/services.dart';

class CnpjInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    
    // Limit to 14 characters
    if (newText.length > 14) {
      newText = newText.substring(0, 14);
    }

    String formatted = formatString(newText);

    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  static String formatString(String value) {
    String newText = value.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (newText.length > 14) {
      newText = newText.substring(0, 14);
    }

    String formatted = '';
    for (int i = 0; i < newText.length; i++) {
      if (i == 2 || i == 5) {
        formatted += '.';
      } else if (i == 8) {
        formatted += '/';
      } else if (i == 12) {
        formatted += '-';
      }
      formatted += newText[i];
    }

    return formatted;
  }
}
