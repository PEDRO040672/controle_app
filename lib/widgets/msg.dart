import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<bool> MSG(
  BuildContext context,
  String titulo,
  String mensagem,
  int tipo, {
  bool destrutivo = false,
}) async {
  bool resultado = false;

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      // Cria um FocusNode dentro do builder para garantir foco em cada chamada
      final focusPrincipal = FocusNode();

      // Força o foco após a rota estar totalmente ativa
      Future.microtask(() {
        if (focusPrincipal.canRequestFocus) {
          FocusScope.of(ctx).requestFocus(focusPrincipal);
        }
      });

      return FocusScope(
        autofocus: true,
        child: FocusTraversalGroup(
          policy: OrderedTraversalPolicy(),
          child: Shortcuts(
            shortcuts: {
              LogicalKeySet(LogicalKeyboardKey.escape): const DismissIntent(),
            },
            child: Actions(
              actions: {
                DismissIntent: CallbackAction<DismissIntent>(
                  onInvoke: (_) {
                    Navigator.of(ctx).pop(false);
                    return null;
                  },
                ),
              },
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                  side: const BorderSide(color: Colors.black, width: 1),
                ),
                title: Row(
                  children: [
                    destrutivo
                        ? const Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.red,
                            size: 28,
                          )
                        : (tipo == 2
                              ? const Icon(
                                  Icons.help_outline,
                                  color: Colors.orange,
                                  size: 28,
                                )
                              : const Icon(
                                  Icons.info_outline,
                                  color: Colors.blue,
                                  size: 28,
                                )),
                    const SizedBox(width: 10),
                    Expanded(child: Text(titulo)),
                  ],
                ),
                content: Text(mensagem),
                actions: tipo == 1
                    ? [
                        ElevatedButton(
                          focusNode: focusPrincipal,
                          autofocus: true, // ✅ foco automático no OK
                          style: _estilo(ctx),
                          onPressed: () {
                            resultado = true;
                            Navigator.of(ctx).pop();
                          },
                          child: const Text("OK"),
                        ),
                      ]
                    : [
                        ElevatedButton(
                          focusNode: focusPrincipal,
                          autofocus: true, // ✅ foco automático no NÃO
                          style: _estilo(ctx),
                          onPressed: () {
                            resultado = false;
                            Navigator.of(ctx).pop();
                          },
                          child: const Text("Não"),
                        ),
                        const SizedBox(width: 5),
                        ElevatedButton(
                          style: _estilo(ctx),
                          onPressed: () {
                            resultado = true;
                            Navigator.of(ctx).pop();
                          },
                          child: const Text("Sim"),
                        ),
                      ],
              ),
            ),
          ),
        ),
      );
    },
  );

  return resultado;
}

// Função auxiliar para o estilo dos botões
ButtonStyle _estilo(BuildContext context) {
  return ButtonStyle(
    backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
      if (states.contains(WidgetState.hovered) ||
          states.contains(WidgetState.focused) ||
          states.contains(WidgetState.pressed)) {
        return Theme.of(context).colorScheme.secondary;
      }
      return Theme.of(context).colorScheme.primary;
    }),
    foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
    side: WidgetStateProperty.resolveWith<BorderSide?>((states) {
      if (states.contains(WidgetState.hovered) ||
          states.contains(WidgetState.focused) ||
          states.contains(WidgetState.pressed)) {
        return const BorderSide(color: Colors.black, width: 1.5);
      }
      return BorderSide.none;
    }),
  );
}
