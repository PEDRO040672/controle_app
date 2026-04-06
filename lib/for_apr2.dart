import 'package:flutter/material.dart';
import 'base_form.dart';
import '../widgets/campo.dart';
import '../widgets/botoes.dart';
import '../models/cadapr_models.dart';
import '../services/cadapr_services.dart';

class ForApr extends BaseFormPage {
  final int? aprTr;

  const ForApr({super.key, required super.onClose, this.aprTr})
    : super(titulo: 'Cadastro APR');

  @override
  State<ForApr> createState() => _ForAprState();
}

class _ForAprState extends BaseFormState<ForApr> {
  final service = CadaprServices();

  bool inclusao = true;

  // ================= CABEÇALHO =================
  final cTr = TextEditingController();
  final cTipo = TextEditingController();
  final cSitu = TextEditingController();
  final cData = TextEditingController();
  final cTit = TextEditingController();
  final cTitNome = TextEditingController();
  final cEqp = TextEditingController();
  final cEqpDesc = TextEditingController();
  final cHtKm = TextEditingController();
  final cObs = TextEditingController();
  final cTotal = TextEditingController();

  // ================= ITENS =================
  final List<List<TextEditingController>> itens = [];
  final List<List<FocusNode>> itensFocus = [];

  // ================= PARCELAS =================
  final List<List<TextEditingController>> parcelas = [];
  final List<List<FocusNode>> parcelasFocus = [];

  double totalItens = 0;
  double totalParcelas = 0;

  bool get isOS => cTipo.text == "OS";

  @override
  void initState() {
    super.initState();
    _addItem();
    _addParcela();
  }

  void _addItem() {
    itens.add([
      TextEditingController(),
      TextEditingController(),
      TextEditingController(),
      TextEditingController(),
      TextEditingController(),
    ]);

    itensFocus.add([
      FocusNode(),
      FocusNode(),
      FocusNode(),
      FocusNode(),
      FocusNode(),
    ]);
  }

  void _addParcela() {
    parcelas.add([
      TextEditingController(),
      TextEditingController(),
      TextEditingController(),
    ]);

    parcelasFocus.add([FocusNode(), FocusNode(), FocusNode()]);
  }

  void recalcular() {
    totalItens = 0;
    totalParcelas = 0;

    for (var r in itens) {
      double qtd = double.tryParse(r[2].text.replaceAll(',', '.')) ?? 0;
      double vl = double.tryParse(r[3].text.replaceAll(',', '.')) ?? 0;
      double tot = qtd * vl;
      r[4].text = tot.toStringAsFixed(2);
      totalItens += tot;
    }

    for (var r in parcelas) {
      totalParcelas += double.tryParse(r[2].text.replaceAll(',', '.')) ?? 0;
    }

    cTotal.text = totalItens.toStringAsFixed(2);

    _atualizarSituacao();

    setState(() {});
  }

  void _atualizarSituacao() {
    if (totalParcelas == 0) {
      cSitu.text = "Ñ Quitado";
    } else if (totalParcelas < totalItens) {
      cSitu.text = "Parcial";
    } else {
      cSitu.text = "Quitado";
    }
  }

  bool get podeGravar => totalItens == totalParcelas;

  @override
  Widget buildBody(BuildContext context) {
    return Column(
      children: [
        _buildCabecalho(),
        const SizedBox(height: 12),
        _buildGridItens(),
        const SizedBox(height: 12),
        _buildGridParcelas(),
        const SizedBox(height: 12),
        _buildTotais(),
        const SizedBox(height: 12),
        _buildBotoes(),
      ],
    );
  }

  // ================= CABEÇALHO =================
  Widget _buildCabecalho() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        Campo(
          tipo: TipoCampo.inteiro,
          titulo: 'TR',
          controller: cTr,
          focusNode: FocusNode(),
          enabled: false,
        ),
        Campo(
          tipo: TipoCampo.texto,
          titulo: 'Tipo',
          controller: cTipo,
          focusNode: FocusNode(),
        ),
        Campo(
          tipo: TipoCampo.texto,
          titulo: 'Situação',
          controller: cSitu,
          focusNode: FocusNode(),
          enabled: false,
        ),
        Campo(
          tipo: TipoCampo.data,
          titulo: 'Data',
          controller: cData,
          focusNode: FocusNode(),
        ),
        Campo(
          tipo: TipoCampo.inteiro,
          titulo: 'Titular',
          controller: cTit,
          focusNode: FocusNode(),
        ),
        Campo(
          tipo: TipoCampo.texto,
          titulo: 'Nome',
          controller: cTitNome,
          focusNode: FocusNode(),
          enabled: false,
        ),
        Campo(
          tipo: TipoCampo.inteiro,
          titulo: 'Equipamento',
          controller: cEqp,
          focusNode: FocusNode(),
        ),
        Campo(
          tipo: TipoCampo.texto,
          titulo: 'Descrição',
          controller: cEqpDesc,
          focusNode: FocusNode(),
          enabled: false,
        ),
        Campo(
          tipo: TipoCampo.double,
          titulo: 'HT/KM',
          controller: cHtKm,
          focusNode: FocusNode(),
        ),
        Campo(
          tipo: TipoCampo.texto,
          titulo: 'Observação',
          controller: cObs,
          focusNode: FocusNode(),
        ),
        Campo(
          tipo: TipoCampo.double,
          titulo: 'Valor Total',
          controller: cTotal,
          focusNode: FocusNode(),
          enabled: false,
        ),
      ],
    );
  }

  // ================= GRID ITENS =================
  Widget _buildGridItens() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Itens", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        SizedBox(
          height: 220,
          child: ListView.builder(
            itemCount: itens.length,
            itemBuilder: (_, i) {
              var r = itens[i];
              var f = itensFocus[i];

              return Row(
                children: [
                  _cell(r[0], f[0], 40),
                  _cell(r[1], f[1], 200),
                  _cell(r[2], f[2], 60, onChanged: (_) => recalcular()),
                  _cell(r[3], f[3], 80, onChanged: (_) => recalcular()),
                  _cell(r[4], f[4], 100, readOnly: true),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  // ================= GRID PARCELAS =================
  Widget _buildGridParcelas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Parcelas", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        SizedBox(
          height: 180,
          child: ListView.builder(
            itemCount: parcelas.length,
            itemBuilder: (_, i) {
              var r = parcelas[i];
              var f = parcelasFocus[i];

              return Row(
                children: [
                  _cell(r[0], f[0], 40),
                  _cell(r[1], f[1], 120),
                  _cell(r[2], f[2], 100, onChanged: (_) => recalcular()),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  // ================= CELL =================
  Widget _cell(
    TextEditingController c,
    FocusNode f,
    double w, {
    bool readOnly = false,
    Function(String)? onChanged,
  }) {
    return SizedBox(
      width: w,
      child: TextField(
        controller: c,
        focusNode: f,
        readOnly: readOnly || isOS,
        onChanged: onChanged,
        decoration: const InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  // ================= TOTAIS =================
  Widget _buildTotais() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Total Itens: ${totalItens.toStringAsFixed(2)}"),
        Text("Total Parcelas: ${totalParcelas.toStringAsFixed(2)}"),
        Text("Diferença: ${(totalItens - totalParcelas).toStringAsFixed(2)}"),
      ],
    );
  }

  // ================= BOTÕES =================
  Widget _buildBotoes() {
    return BotoesFormulario(
      inclusao: inclusao,
      bloqueado: isOS,
      habilitado: !podeGravar,
      onGravar: _gravar,
      onExcluir: _excluir,
      onCancelar: widget.onClose,
    );
  }

  // ================= GRAVAR =================
  Future<void> _gravar() async {
    if (!podeGravar) return;

    final cad = Cadapr(
      apr_tr: int.tryParse(cTr.text) ?? 0,
      apr_tipo: cTipo.text,
      apr_situ: cSitu.text,
      apr_data: DateTime.now(),
      apr_tit: int.tryParse(cTit.text) ?? 0,
      apr_eqp: int.tryParse(cEqp.text) ?? 0,
      apr_htkm: double.tryParse(cHtKm.text) ?? 0,
      apr_obs: cObs.text,
      apr_vltot: totalItens,
      itens: [],
      parcelas: [],
    );

    if (inclusao) {
      await service.add(cad);
    } else {
      await service.update(cad);
    }

    widget.onClose();
  }

  // ================= EXCLUIR =================
  Future<void> _excluir() async {
    if (cTr.text.isEmpty) return;

    await service.delete(int.parse(cTr.text));
    widget.onClose();
  }
}
