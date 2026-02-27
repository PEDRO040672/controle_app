import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

import 'base_form.dart';

abstract class BaseConsPage extends StatefulWidget {
  final String titulo;

  const BaseConsPage({super.key, required this.titulo});
}

abstract class BaseConsState<T extends BaseConsPage> extends State<T> {
  final FocusNode gridFocus = FocusNode();
  final FocusNode filtroFocus = FocusNode();

  bool get isDesktop {
    if (kIsWeb) return true;
    final p = Theme.of(context).platform;
    return p == TargetPlatform.windows ||
        p == TargetPlatform.linux ||
        p == TargetPlatform.macOS;
  }

  /// ===============================
  /// MÉTODOS QUE A CONSULTA IMPLEMENTA
  /// ===============================

  Future<void> carregar();

  Widget buildFiltro(BuildContext context);

  Widget buildTabela(BuildContext context);

  void mover(int delta);

  void selecionarAtual();

  /// ===============================
  /// COMPORTAMENTO PADRÃO DE TECLADO
  /// ===============================

  void onEscape() {
    Navigator.of(context).pop();
  }

  void handleKey(KeyEvent event) {
    if (!isDesktop) return;

    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        onEscape();
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        mover(1);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        mover(-1);
      } else if (event.logicalKey == LogicalKeyboardKey.enter) {
        selecionarAtual();
      } else if (event.logicalKey == LogicalKeyboardKey.f5) {
        carregar();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    carregar();
  }

  @override
  void dispose() {
    gridFocus.dispose();
    filtroFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54,
      body: SafeArea(
        child: Center(
          child: BaseFormContainer(
            child: KeyboardListener(
              autofocus: true,
              focusNode: gridFocus,
              onKeyEvent: handleKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BaseFormHeader(titulo: widget.titulo, onClose: onEscape),
                  const SizedBox(height: 20),
                  buildFiltro(context),
                  const SizedBox(height: 16),
                  Expanded(child: buildTabela(context)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
