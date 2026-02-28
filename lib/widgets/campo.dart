import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum TipoCampo { texto, inteiro, moeda, data, mascara }

class Campo extends StatelessWidget {
  final TipoCampo tipo;

  final String titulo;
  final TextEditingController controller;
  final FocusNode focusNode;
  final FocusNode? nextFocus;
  final Future<bool> Function()? onSubmitted;

  final int tamanho; // texto / inteiro
  final bool zeroEsquerda; // inteiro
  final String? mascara; // moeda / mascara
  final bool enabled;
  final bool autofocus;

  const Campo({
    super.key,
    required this.tipo,
    required this.titulo,
    required this.controller,
    required this.focusNode,
    this.nextFocus,
    this.onSubmitted,
    this.tamanho = 50,
    this.zeroEsquerda = false,
    this.mascara,
    this.enabled = true,
    this.autofocus = false,
  });

  // ==========================
  // LARGURA DINÂMICA
  // ==========================
  double _largura(BuildContext context) {
    final estilo = _estilo(context);

    // Texto base para cálculo
    String textoBase;

    switch (tipo) {
      case TipoCampo.texto:
      case TipoCampo.inteiro:
        textoBase = 'W' * tamanho;
        break;

      case TipoCampo.moeda:
      case TipoCampo.mascara:
        textoBase = mascara ?? 'W' * 10;
        break;

      case TipoCampo.data:
        textoBase = '99/99/9999';
        break;
    }

    final textPainter = TextPainter(
      text: TextSpan(text: textoBase, style: estilo),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();

    return textPainter.width + 24; // margem interna
  }

  // ==========================
  // KEYBOARD
  // ==========================
  TextInputType _keyboard() {
    switch (tipo) {
      case TipoCampo.inteiro:
      case TipoCampo.moeda:
      case TipoCampo.data:
        return TextInputType.number;
      default:
        return TextInputType.text;
    }
  }

  // ==========================
  // ALINHAMENTO
  // ==========================
  TextAlign _align() {
    switch (tipo) {
      case TipoCampo.inteiro:
      case TipoCampo.moeda:
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

      case TipoCampo.moeda:
        if (mascara == null) return null;
        return [MaskTextInputFormatter(mascara!)];

      case TipoCampo.mascara:
        if (mascara == null) return null;
        return [MaskTextInputFormatter(mascara!)];

      case TipoCampo.data:
        return [MaskTextInputFormatter('99/99/9999')];
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

      case TipoCampo.moeda:
      case TipoCampo.mascara:
        return mascara?.length;

      case TipoCampo.data:
        return 10;
    }
  }

  // ==========================
  // SUBMIT CENTRALIZADO
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
      FocusScope.of(context).nextFocus(); // 👈 melhor que unfocus()
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
        textInputAction: TextInputAction.next, // 👈 IMPORTANTE
        inputFormatters: _formatters(),
        onSubmitted: (_) => _handleSubmit(context), // 👈 ENTER
        decoration: InputDecoration(
          isDense: true, // altera o espaçamento para o minimo interna do label
          filled: true,
          fillColor: enabled ? Colors.grey.shade300 : Colors.grey.shade500,
          labelText: titulo,
          counterText: '',
          border: const OutlineInputBorder(),

          contentPadding: const EdgeInsets.symmetric(
            horizontal: 5,
            vertical: 11,
          ),
        ),
      ),
    );
  }

  // ==========================
  // UTILITÁRIOS MOEDA
  // ==========================
  static double textDouble(String text) {
    final clean = text.replaceAll(RegExp(r'[^\d,]'), '');
    if (clean.isEmpty) return 0.0;

    return double.parse(clean.replaceAll('.', '').replaceAll(',', '.'));
  }

  static String doubleText(double value, String mascara) {
    final casasDecimais = mascara.contains(',')
        ? mascara.split(',').last.length
        : 0;

    final texto = value.toStringAsFixed(casasDecimais);

    final partes = texto.split('.');
    final inteiro = partes[0];
    final decimal = partes.length > 1 ? partes[1] : '';

    String formatado = inteiro.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );

    if (casasDecimais > 0) {
      formatado = '$formatado,$decimal';
    }

    if (mascara.contains('R\$')) {
      formatado = 'R\$ $formatado';
    }

    return formatado;
  }
}

// ==========================
// FORMATTER MÁSCARA
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
        // dígito obrigatório
        buffer.write(v);
        maskIndex++;
        valueIndex++;
      } else if (m == 'A' && _isLetter(v)) {
        // letra obrigatória
        buffer.write(v.toUpperCase());
        maskIndex++;
        valueIndex++;
      } else if (m == '?') {
        // aceita dígito ou espaço
        if (valueIndex < value.length) {
          final char = value[valueIndex];
          if (_isDigit(char) || char == ' ') {
            buffer.write(char);
            valueIndex++;
          }
        }
        // sempre avançamos na máscara, mesmo que o usuário não digite nada
        maskIndex++;
      } else {
        // caracteres fixos da máscara (como (, ), -, /, espaço)
        buffer.write(m);
        // só avançamos no valor se o caractere do usuário coincidir com o literal
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
// FORMATTER UPPERCASE
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
// Estilo de fonte
// ==========================
TextStyle _estilo(BuildContext context) {
  return Theme.of(context).textTheme.bodyMedium?.copyWith(
        fontSize: 16,
        //fontWeight: FontWeight.w400,
        fontFamily: 'RobotoMono', // fonte equivalente a CourrierNew
      ) ??
      const TextStyle(
        fontSize: 16,
        //fontWeight: FontWeight.w400,
      );
}
