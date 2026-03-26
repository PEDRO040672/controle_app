import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum TipoCampo { texto, inteiro, double, data, mascara, lista }

class Campo extends StatelessWidget {
  final TipoCampo tipo;

  final String titulo;
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback? onDoubleTap;
  final FocusNode? nextFocus;
  final Future<bool> Function()? onSubmitted;
  final String? lista;

  final int tamanho;
  final bool zeroEsquerda;
  final String? mascara;
  final bool enabled;
  final bool autofocus;

  const Campo({
    super.key,
    required this.tipo,
    required this.titulo,
    required this.controller,
    required this.focusNode,
    this.onDoubleTap,
    this.nextFocus,
    this.onSubmitted,
    this.tamanho = 50,
    this.zeroEsquerda = false,
    this.mascara,
    this.enabled = true,
    this.autofocus = false,
    this.lista,
  });

  // ==========================
  // LARGURA
  // ==========================
  double _largura(BuildContext context) {
    final estilo = _estilo(context);

    String base;
    switch (tipo) {
      case TipoCampo.texto:
        base = 'W' * (tamanho + 7);
        break;
      case TipoCampo.inteiro:
        base = 'W' * (tamanho + 3);
        break;
      case TipoCampo.double:
        base = mascara != null ? '$mascara   ' : 'W' * 12;
        break;
      case TipoCampo.mascara:
        base = mascara != null ? '$mascara    ' : 'W' * 12;
        break;
      case TipoCampo.data:
        base = '99/99/9999   ';
        break;
      case TipoCampo.lista:
        final itens = (lista ?? '')
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
        if (itens.isEmpty) {
          base = 'WWWW';
        } else {
          // pega o maior texto
          final maior = itens.reduce((a, b) => a.length > b.length ? a : b);
          // adiciona uma folga (ícone do dropdown + padding)
          base = '$maior  ';
        }
        break;
    }

    final tp = TextPainter(
      text: TextSpan(text: base, style: estilo),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();

    return tp.width + 10;
  }

  // ==========================
  // KEYBOARD
  // ==========================
  TextInputType _keyboard() {
    switch (tipo) {
      case TipoCampo.inteiro:
      case TipoCampo.double:
      case TipoCampo.data:
        return const TextInputType.numberWithOptions(decimal: true);
      case TipoCampo.lista:
        return TextInputType.none;
      default:
        return TextInputType.text;
    }
  }

  // ==========================
  // ALIGN
  // ==========================
  TextAlign _align() {
    switch (tipo) {
      case TipoCampo.inteiro:
      case TipoCampo.double:
        return TextAlign.right;
      default:
        return TextAlign.left;
    }
  }

  // ==========================
  // FORMATTERS
  // ==========================
  List<TextInputFormatter>? _formatters() {
    switch (tipo) {
      case TipoCampo.texto:
        return [UpperCaseTextFormatter()];

      case TipoCampo.inteiro:
        return [FilteringTextInputFormatter.digitsOnly];

      case TipoCampo.double:
        int casas = 0;
        int inteiros = 0;
        bool moeda = false;

        if (mascara != null) {
          moeda = mascara!.contains('R\$');

          final limpa = mascara!.replaceAll('R\$', '').trim();

          if (limpa.contains(',')) {
            final partes = limpa.split(',');
            casas = partes[1].length;
            inteiros = partes[0].replaceAll('.', '').length;
          } else {
            inteiros = limpa.replaceAll('.', '').length;
          }
        }

        return [
          MoneyTextInputFormatter(
            decimalRange: casas,
            integerRange: inteiros,
            isCurrency: moeda,
            allowNegative: true,
          ),
        ];
      case TipoCampo.mascara:
        if (mascara == null) return null;
        return [MaskTextInputFormatter(mascara!)];

      case TipoCampo.data:
        return [MaskTextInputFormatter('99/99/9999')];

      case TipoCampo.lista:
        return null;
    }
  }

  // ==========================
  // MAX LENGTH
  // ==========================
  int? _maxLength() {
    switch (tipo) {
      case TipoCampo.texto:
      case TipoCampo.inteiro:
        return tamanho;
      case TipoCampo.mascara:
        return mascara?.length;
      case TipoCampo.data:
        return 10;
      case TipoCampo.lista:
        return null;
      case TipoCampo.double:
        return null; // 👈 importante
    }
  }

  // ==========================
  // SUBMIT
  // ==========================
  Future<void> _handleSubmit(BuildContext context) async {
    if (tipo == TipoCampo.inteiro && zeroEsquerda) {
      if (controller.text.isNotEmpty) {
        controller.text = controller.text.padLeft(tamanho, '0');
      }
    }

    bool podeAvancar = true;

    if (onSubmitted != null) {
      podeAvancar = await onSubmitted!();
    }

    if (!podeAvancar) {
      focusNode.requestFocus();
      return;
    }

    if (nextFocus != null) {
      FocusScope.of(context).requestFocus(nextFocus);
    } else {
      FocusScope.of(context).nextFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (tipo == TipoCampo.lista) {
      final itens = (lista ?? '')
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      return SizedBox(
        width: _largura(context) + 30,
        child: DropdownButtonFormField<String>(
          value: controller.text.isEmpty ? null : controller.text,
          focusNode: focusNode,
          autofocus: autofocus,
          isDense: true,
          style: _estilo(
            context,
          ).copyWith(color: enabled ? null : Theme.of(context).disabledColor),
          iconEnabledColor: Theme.of(context).iconTheme.color,
          iconDisabledColor: Theme.of(context).disabledColor,
          decoration: _decoracao(),
          items: itens
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: enabled
              ? (value) {
                  controller.text = value ?? '';
                  _handleSubmit(context);
                }
              : null,
        ),
      );
    }

    return GestureDetector(
      onDoubleTap: enabled ? onDoubleTap : null,
      child: SizedBox(
        width: _largura(context),
        child: TextField(
          focusNode: focusNode,
          autofocus: autofocus,
          controller: controller,
          enabled: enabled,
          style: _estilo(context),
          maxLength: _maxLength(),
          keyboardType: _keyboard(),
          textAlign: _align(),
          textInputAction: TextInputAction.next,
          inputFormatters: _formatters(),
          onSubmitted: (_) => _handleSubmit(context),
          decoration: _decoracao(),
        ),
      ),
    );
  }

  InputDecoration _decoracao() {
    return InputDecoration(
      isDense: true,
      filled: true,
      fillColor: enabled ? Colors.grey.shade300 : Colors.grey.shade500,
      labelText: titulo,
      counterText: '',
      border: const OutlineInputBorder(),
      contentPadding: const EdgeInsets.symmetric(horizontal: 5, vertical: 7),
    );
  }

  // ==========================
  // UTIL
  // ==========================
  static double textDouble(String text) {
    if (text.trim().isEmpty) return 0.0;

    final normalized = text
        .replaceAll('R\$', '')
        .replaceAll(' ', '')
        .replaceAll('.', '')
        .replaceAll(',', '.');

    return double.tryParse(normalized) ?? 0.0;
  }

  static String doubleText(double value, String mascara) {
    final casas = mascara.contains(',') ? mascara.split(',').last.length : 0;

    final texto = value.toStringAsFixed(casas);
    final partes = texto.split('.');

    String inteiro = partes[0];
    String decimal = partes.length > 1 ? partes[1] : '';

    inteiro = inteiro.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );

    return casas > 0 ? '$inteiro,$decimal' : inteiro;
  }
}

// ==========================
// DECIMAL FORMATTER
// ==========================
class MoneyTextInputFormatter extends TextInputFormatter {
  final int decimalRange;
  final int integerRange;
  final bool isCurrency;
  final bool allowNegative;

  MoneyTextInputFormatter({
    required this.decimalRange,
    required this.integerRange,
    this.isCurrency = false,
    this.allowNegative = false,
  });

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text;

    // 🔥 detecta negativo (mesmo digitando em qualquer posição)
    bool isNegative = false;

    if (allowNegative) {
      if (text.contains('-')) {
        isNegative = true;
      }
    }

    // remove tudo que não for número
    String digits = text.replaceAll(RegExp(r'\D'), '');

    if (digits.isEmpty) {
      return const TextEditingValue(text: '');
    }

    int maxDigits = integerRange + decimalRange;
    if (digits.length > maxDigits) {
      digits = digits.substring(0, maxDigits);
    }

    // garante tamanho mínimo
    while (digits.length <= decimalRange) {
      digits = '0$digits';
    }

    String inteiro = digits.substring(0, digits.length - decimalRange);
    String decimal = digits.substring(digits.length - decimalRange);

    // remove zeros à esquerda
    inteiro = inteiro.replaceFirst(RegExp(r'^0+'), '');
    if (inteiro.isEmpty) inteiro = '0';

    // limita inteiro
    if (inteiro.length > integerRange) {
      inteiro = inteiro.substring(inteiro.length - integerRange);
    }

    // milhar
    inteiro = inteiro.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );

    String result = decimalRange > 0 ? '$inteiro,$decimal' : inteiro;

    // adiciona moeda
    if (isCurrency) {
      result = 'R\$ $result';
    }

    // adiciona negativo
    if (isNegative) {
      result = '-$result';
    }

    return TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: result.length),
    );
  }
}

// ==========================
// MASK FORMATTER
// ==========================
class MaskTextInputFormatter extends TextInputFormatter {
  final String mask;

  MaskTextInputFormatter(this.mask);

  bool _isDigit(String c) => RegExp(r'\d').hasMatch(c);
  bool _isLetter(String c) => RegExp(r'[a-zA-Z]').hasMatch(c);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final buffer = StringBuffer();
    int maskIndex = 0;
    int valueIndex = 0;
    final value = newValue.text;

    while (maskIndex < mask.length && valueIndex < value.length) {
      final m = mask[maskIndex];
      final v = value[valueIndex];

      if (m == '9' && _isDigit(v)) {
        buffer.write(v);
        maskIndex++;
        valueIndex++;
      } else if (m == 'A' && _isLetter(v)) {
        buffer.write(v.toUpperCase());
        maskIndex++;
        valueIndex++;
      } else {
        buffer.write(m);
        if (v == m) valueIndex++;
        maskIndex++;
      }
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

// ==========================
// UPPERCASE
// ==========================
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

// ==========================
// ESTILO
// ==========================
TextStyle _estilo(BuildContext context) {
  return Theme.of(context).textTheme.bodyMedium?.copyWith(
        fontSize: 15,
        fontFamily: 'RobotoMono',
      ) ??
      const TextStyle(fontSize: 15);
}
