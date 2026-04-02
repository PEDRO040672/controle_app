import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'msg.dart';

/// ======================================================
/// BOTÃO PADRÃO FORMULÁRIO [Gravar] [Excluir] [Cancelar]
/// ======================================================
class BotoesFormulario extends StatelessWidget {
  final bool habilitado;
  final bool inclusao;
  final VoidCallback onGravar;
  final Future<void> Function() onExcluir;
  final VoidCallback onCancelar;
  final FocusNode? focusGravar;
  final bool bloqueado;

  const BotoesFormulario({
    super.key,
    required this.habilitado,
    required this.inclusao,
    required this.onGravar,
    required this.onExcluir,
    required this.onCancelar,
    this.focusGravar,
    this.bloqueado = false,
  });

  ButtonStyle _estiloBotao(BuildContext context) {
    return ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.disabled)) {
          return Colors.grey.shade300;
        }
        if (states.contains(WidgetState.focused) ||
            states.contains(WidgetState.hovered) ||
            states.contains(WidgetState.pressed)) {
          return Theme.of(context).colorScheme.secondary;
        }
        return Theme.of(context).colorScheme.primary;
      }),
      foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.disabled)) {
          return Colors.grey.shade600;
        }
        return Colors.white;
      }),
      // 👇 AQUI está a borda dinâmica
      side: WidgetStateProperty.resolveWith<BorderSide?>((states) {
        if (states.contains(WidgetState.hovered) ||
            states.contains(WidgetState.focused) ||
            states.contains(WidgetState.pressed)) {
          return const BorderSide(color: Colors.black, width: 1.5);
        }
        return BorderSide.none;
      }),
      padding: WidgetStateProperty.all(
        const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final estiloBotao = _estiloBotao(context);
    return Shortcuts(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.escape): const DismissIntent(),
      },
      child: Actions(
        actions: {
          DismissIntent: CallbackAction<DismissIntent>(
            onInvoke: (_) {
              if (!habilitado) {
                onCancelar();
              }
              return null;
            },
          ),
        },
        child: Center(
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              /// GRAVAR
              ElevatedButton(
                style: estiloBotao,
                focusNode: focusGravar,
                onPressed: !habilitado ? onGravar : null,
                child: const Text('Gravar'),
              ),

              /// EXCLUIR
              ElevatedButton(
                style: estiloBotao,
                onPressed: (!habilitado && !inclusao && !bloqueado)
                    ? () async {
                        bool confirmar = await MSG(
                          context,
                          'Excluir Registro',
                          'Confirma a EXCLUSÃO do registro?',
                          2,
                          destrutivo: true,
                        );
                        if (confirmar) {
                          await onExcluir();
                        }
                      }
                    : null,
                child: const Text('Excluir'),
              ),

              /// CANCELAR
              ElevatedButton(
                style: estiloBotao,
                onPressed: !habilitado
                    ? () {
                        FocusScope.of(context).unfocus(); // 👈 ADICIONE ISSO
                        onCancelar();
                      }
                    : null,
                child: const Text('Cancelar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
