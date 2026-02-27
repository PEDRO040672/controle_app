import 'package:flutter/material.dart';

class BotaoConsulta extends StatelessWidget {
  final VoidCallback? onPressed;
  final String tooltip;
  final double height;

  const BotaoConsulta({
    super.key,
    required this.onPressed,
    this.tooltip = 'Consultar',
    this.height = 50,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: IconButton(
        tooltip: tooltip,
        icon: const Icon(Icons.search),
        onPressed: onPressed,
        style: ButtonStyle(
          side: WidgetStateProperty.resolveWith<BorderSide?>((states) {
            if (states.contains(WidgetState.focused) ||
                states.contains(WidgetState.hovered) ||
                states.contains(WidgetState.pressed)) {
              return const BorderSide(color: Colors.black, width: 1.5);
            }
            return null;
          }),
          backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.focused) ||
                states.contains(WidgetState.hovered) ||
                states.contains(WidgetState.pressed)) {
              return Theme.of(context).colorScheme.secondary;
            }
            if (states.contains(WidgetState.disabled)) {
              return Colors.grey.shade500;
            }
            return Theme.of(context).colorScheme.primary;
          }),
        ),
      ),
    );
  }
}
