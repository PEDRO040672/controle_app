import 'package:flutter/services.dart';

class MoedaMaskFormatter extends TextInputFormatter {
  final String mascara;

  MoedaMaskFormatter(this.mascara);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');

    if (digits.isEmpty) {
      return const TextEditingValue(text: '');
    }

    final buffer = StringBuffer();
    int digitIndex = digits.length - 1;

    for (int i = mascara.length - 1; i >= 0; i--) {
      final m = mascara[i];

      if (m == '9') {
        if (digitIndex >= 0) {
          buffer.write(digits[digitIndex]);
          digitIndex--;
        } else {
          buffer.write('0');
        }
      } else {
        buffer.write(m);
      }
    }

    final text = buffer.toString();

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
