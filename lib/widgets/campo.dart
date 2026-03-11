import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum TipoCampo { texto, inteiro, moeda, data, mascara, uf }

class Campo extends StatelessWidget {
  final TipoCampo tipo;

  final String titulo;
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback? onDoubleTap;
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
    this.onDoubleTap,
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
        textoBase = 'W' * (tamanho + 1);
        break;
      case TipoCampo.moeda:
      case TipoCampo.mascara:
        if (mascara == null) {
          textoBase = 'W' * 10;
        } else {
          textoBase = '${mascara}WWW';
        }
        break;
      case TipoCampo.data:
        textoBase = '99/99/9999WW';
        break;
      case TipoCampo.uf:
        textoBase = 'WWW'; // largura para sigla
        break;
    }
    final textPainter = TextPainter(
      text: TextSpan(text: textoBase, style: estilo),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    return textPainter.width + 10; // margem interna
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
      case TipoCampo.uf:
        return TextInputType.none;
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

      case TipoCampo.uf:
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
      case TipoCampo.moeda:
      case TipoCampo.mascara:
        return mascara?.length;
      case TipoCampo.data:
        return 10;
      case TipoCampo.uf:
        return 2;
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
    if (tipo == TipoCampo.uf) {
      return SizedBox(
        width: _largura(context) + 30, // espaço da seta
        child: DropdownButtonFormField<String>(
          value: controller.text.isEmpty ? null : controller.text,
          focusNode: focusNode,
          autofocus: autofocus,
          isDense: true,
          style: _estilo(context),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: enabled ? Colors.grey.shade300 : Colors.grey.shade500,
            labelText: titulo,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 5,
              vertical: 10,
            ),
          ),
          items: _ufs
              .map((uf) => DropdownMenuItem<String>(value: uf, child: Text(uf)))
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

    // comportamento padrão (TextField)
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
          onTap: () {
            focusNode.onKeyEvent = (node, event) {
              if (event is KeyDownEvent &&
                  event.logicalKey == LogicalKeyboardKey.f2 &&
                  onDoubleTap != null &&
                  enabled) {
                onDoubleTap!();
                return KeyEventResult.handled;
              }
              return KeyEventResult.ignored;
            };
          },
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: enabled ? Colors.grey.shade300 : Colors.grey.shade500,
            labelText: titulo,
            counterText: '',
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 5,
              vertical: 10,
            ),
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

  // ==========================
  // UTILITÁRIOS UF
  // ==========================
  static const List<String> _ufs = [
    'AC',
    'AL',
    'AP',
    'AM',
    'BA',
    'CE',
    'DF',
    'ES',
    'GO',
    'MA',
    'MT',
    'MS',
    'MG',
    'PA',
    'PB',
    'PR',
    'PE',
    'PI',
    'RJ',
    'RN',
    'RS',
    'RO',
    'RR',
    'SC',
    'SP',
    'SE',
    'TO',
  ];
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
