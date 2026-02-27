import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// ======================================================
/// CONTAINER BASE RESPONSIVO
/// ======================================================

class BaseFormContainer extends StatelessWidget {
  final Widget child;

  const BaseFormContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 900;

        if (isDesktop) {
          return Align(
            alignment: Alignment.center,
            child: Container(
              width: 700,
              padding: const EdgeInsets.all(28),
              decoration: _decoration(context),
              child: child,
            ),
          );
        }

        return Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: _decoration(context),
              child: child,
            ),
          ),
        );
      },
    );
  }

  BoxDecoration _decoration(BuildContext context) {
    return BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      boxShadow: [
        BoxShadow(
          color: Colors.black87,
          blurRadius: 25,
          offset: const Offset(0, 12),
        ),
      ],
    );
  }
}

/// ======================================================
/// BASE DE PÁGINA DE FORMULÁRIO
/// ======================================================

abstract class BaseFormPage extends StatefulWidget {
  final String titulo;
  final VoidCallback onClose;

  const BaseFormPage({super.key, required this.titulo, required this.onClose});
}

abstract class BaseFormState<T extends BaseFormPage> extends State<T> {
  final FocusScopeNode _formFocusScope = FocusScopeNode();

  /// Corpo do formulário
  Widget buildBody(BuildContext context);

  /// ESC padrão
  void onEscapePressed() {
    widget.onClose();
  }

  /// Override opcional
  void limparFormulario() {}

  @override
  void dispose() {
    _formFocusScope.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FocusScope(
      node: _formFocusScope,
      autofocus: true,
      //autofocus: false,
      child: Shortcuts(
        shortcuts: {
          LogicalKeySet(LogicalKeyboardKey.escape): const ActivateIntent(),
        },
        child: Actions(
          actions: {
            ActivateIntent: CallbackAction<Intent>(
              onInvoke: (_) {
                onEscapePressed();
                return null;
              },
            ),
          },
          child: BaseFormContainer(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BaseFormHeader(titulo: widget.titulo, onClose: widget.onClose),
                const SizedBox(height: 24),
                buildBody(context), // ← ISSO É OBRIGATÓRIO
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ======================================================
/// HEADER ERP MODERNO (SEM BOTÃO X)
/// ======================================================

//class _FormHeader extends StatelessWidget {
class BaseFormHeader extends StatelessWidget {
  final String titulo;
  final VoidCallback onClose;

  //const _FormHeader({required this.titulo, required this.onClose});
  const BaseFormHeader({
    super.key,
    required this.titulo,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withOpacity(0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          // BOTÃO X PADRÃO
          IconButton(
            onPressed: onClose,
            style: IconButton.styleFrom(
              backgroundColor: Colors.white30,
              shape: const CircleBorder(),
            ),
            icon: const Icon(Icons.close),
            color: Colors.white,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              titulo,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
