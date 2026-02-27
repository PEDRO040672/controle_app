import 'package:flutter/services.dart';

class RightToLeftNumberFormatter extends TextInputFormatter {
  final int maxLength;
  final bool padWithZeros;

  RightToLeftNumberFormatter(this.maxLength, {this.padWithZeros = true});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');

    final limited = digits.length > maxLength
        ? digits.substring(digits.length - maxLength)
        : digits;

    final text = padWithZeros ? limited.padLeft(maxLength, '0') : limited;

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
