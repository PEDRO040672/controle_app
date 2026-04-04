import 'package:flutter/material.dart';
import 'base_form.dart';
import '../widgets/campo.dart';
import '../widgets/botoes.dart';

class ForApr extends BaseFormPage {
  const ForApr({super.key, required super.onClose})
    : super(titulo: 'Contas a Pagar / Receber');

  @override
  State<ForApr> createState() => _ForAprState();
}

class _ForAprState extends BaseFormState<ForApr> {
  // Controllers
  final _tr = TextEditingController(text: '0');
  final _tipo = TextEditingController();
  final _data = TextEditingController();
  final _tit = TextEditingController();
  final _eqp = TextEditingController();
  final _htkm = TextEditingController();
  final _obs = TextEditingController();
  final _total = TextEditingController();

  // Focus
  final _fTr = FocusNode();
  final _fTipo = FocusNode();
  final _fData = FocusNode();
  final _fTit = FocusNode();
  final _fEqp = FocusNode();
  final _fHtkm = FocusNode();
  final _fObs = FocusNode();

  bool inclusao = true;

  @override
  Widget buildBody(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Campo(
              tipo: TipoCampo.inteiro,
              titulo: 'TR',
              controller: _tr,
              focusNode: _fTr,
              nextFocus: _fTipo,
              tamanho: 6,
            ),
            Campo(
              tipo: TipoCampo.lista,
              titulo: 'Tipo',
              controller: _tipo,
              focusNode: _fTipo,
              nextFocus: _fData,
              lista: 'A_Pagar,A_Receber',
            ),
            Campo(
              tipo: TipoCampo.data,
              titulo: 'Data',
              controller: _data,
              focusNode: _fData,
              nextFocus: _fTit,
            ),
            Campo(
              tipo: TipoCampo.inteiro,
              titulo: 'Titular',
              controller: _tit,
              focusNode: _fTit,
              nextFocus: _fEqp,
              tamanho: 6,
            ),
            Campo(
              tipo: TipoCampo.inteiro,
              titulo: 'Equip',
              controller: _eqp,
              focusNode: _fEqp,
              nextFocus: _fHtkm,
              tamanho: 6,
            ),
            Campo(
              tipo: TipoCampo.double,
              titulo: 'HT/KM',
              controller: _htkm,
              focusNode: _fHtkm,
              nextFocus: _fObs,
              mascara: '999.999,9',
            ),
            Campo(
              tipo: TipoCampo.texto,
              titulo: 'Observação',
              controller: _obs,
              focusNode: _fObs,
              tamanho: 40,
            ),
            Campo(
              tipo: TipoCampo.double,
              titulo: 'Total',
              controller: _total,
              focusNode: FocusNode(),
              mascara: '999.999,99',
              enabled: false,
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Divider(),
        const SizedBox(height: 20),

        // ITENS placeholder
        const Text('Itens', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          height: 120,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(child: Text('Grid de Itens')),
        ),

        const SizedBox(height: 20),

        // PARCELAS placeholder
        const Text('Parcelas', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          height: 120,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(child: Text('Grid de Parcelas')),
        ),

        const SizedBox(height: 20),

        BotoesFormulario(
          habilitado: false,
          inclusao: inclusao,
          onGravar: _gravar,
          onExcluir: _excluir,
          onCancelar: widget.onClose,
        ),
      ],
    );
  }

  void _gravar() {
    // TODO implementar
  }

  Future<void> _excluir() async {
    // TODO implementar
  }
}
