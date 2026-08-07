import 'package:flutter/services.dart';

class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    
    // Limit to 11 characters
    if (newText.length > 11) {
      newText = newText.substring(0, 11);
    }

    String formatted = formatString(newText);

    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  static String formatString(String value) {
    String newText = value.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (newText.length > 11) {
      newText = newText.substring(0, 11);
    }

    String formatted = '';
    for (int i = 0; i < newText.length; i++) {
      if (i == 0) {
        formatted += '(';
      } else if (i == 2) {
        formatted += ') ';
      } else if (newText.length == 11 && i == 7) {
        // 9-digit phone
        formatted += '-';
      } else if (newText.length < 11 && i == 6) {
        // 8-digit phone
        formatted += '-';
      }
      formatted += newText[i];
    }

    return formatted;
  }
}
