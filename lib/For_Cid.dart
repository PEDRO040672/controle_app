import 'package:flutter/material.dart';

class ForCid extends StatelessWidget {
  final VoidCallback onClose;

  const ForCid({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Cidades'),
        leading: IconButton(icon: const Icon(Icons.close), onPressed: onClose),
      ),
      body: const Center(child: Text('Formulário de Cidades aqui')),
    );
  }
}
