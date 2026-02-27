import 'package:flutter/services.dart';

class MaskFormatter extends TextInputFormatter {
  final String mask;

  MaskFormatter(this.mask);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text;

    StringBuffer buffer = StringBuffer();
    int index = 0;

    for (int i = 0; i < mask.length; i++) {
      if (index >= digits.length) break;

      final m = mask[i];
      final c = digits[index];

      if (m == '9' && RegExp(r'\d').hasMatch(c)) {
        buffer.write(c);
        index++;
      } else if (m == 'A' && RegExp(r'[A-Za-z]').hasMatch(c)) {
        buffer.write(c.toUpperCase());
        index++;
      } else if (m == '?' && c == ' ') {
        buffer.write(c);
        index++;
      } else if (m != '9' && m != 'A' && m != '?') {
        buffer.write(m);
        if (c == m) index++;
      } else {
        // ignora caracteres que não batem com a máscara
        index++;
      }
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}
