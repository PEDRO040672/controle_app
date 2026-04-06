import 'package:flutter/material.dart';
import 'base_form.dart';
import '../widgets/campo.dart';
import '../widgets/botoes.dart';
import '../models/cadapr_models.dart';
//import '../models/cadipr_models.dart';
//import '../models/cadppr_models.dart';
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

  // ================= GRID =================
  final List<List<TextEditingController>> itens = [];
  final List<List<FocusNode>> itensFocus = [];

  final List<List<TextEditingController>> parcelas = [];
  final List<List<FocusNode>> parcelasFocus = [];

  double totalItens = 0;
  double totalParcelas = 0;

  bool get isOS => cTipo.text == "OS";

  @override
  void initState() {
    super.initState();

    if (widget.aprTr != null) {
      inclusao = false;
      carregar(widget.aprTr!);
    } else {
      _addItem();
      _addParcela();
    }
  }

  Future<void> carregar(int id) async {
    final data = await service.getById(id);
    if (data == null) return;

    final cad = Cadapr.fromJson({
      ...data['cabecalho'],
      "itens": data['itens'],
      "parcelas": data['parcelas'],
    });

    cTr.text = cad.apr_tr.toString();
    cTipo.text = cad.apr_tipo;
    cSitu.text = cad.apr_situ;
    cData.text = Campo.dataFromPg(cad.apr_data.toString());
    cTit.text = cad.apr_tit.toString();
    cTitNome.text = cad.tit_nome ?? '';
    cEqp.text = cad.apr_eqp.toString();
    cEqpDesc.text = cad.eqp_desc ?? '';
    cHtKm.text = cad.apr_htkm.toString();
    cObs.text = cad.apr_obs;

    for (var i in cad.itens) {
      _addItem();
      itens.last[0].text = i.ipr_his.toString();
      itens.last[1].text = i.his_desc ?? '';
      itens.last[2].text = i.ipr_qtd.toString();
      itens.last[3].text = i.ipr_vlunit.toString();
    }

    for (var p in cad.parcelas) {
      _addParcela();
      parcelas.last[0].text = p.ppr_pc.toString();
      parcelas.last[1].text = Campo.dataFromPg(p.ppr_dtv.toString());
      parcelas.last[2].text = p.ppr_vlpc.toString();
    }

    recalcular();
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

    if (totalParcelas == 0) {
      cSitu.text = "Ñ Quitado";
    } else if (totalParcelas < totalItens) {
      cSitu.text = "Parcial";
    } else {
      cSitu.text = "Quitado";
    }

    setState(() {});
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

  Widget _buildCabecalho() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Campo(
                tipo: TipoCampo.inteiro,
                titulo: 'TR',
                controller: cTr,
                focusNode: FocusNode(),
                enabled: false,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Campo(
                tipo: TipoCampo.lista,
                titulo: 'Tipo',
                controller: cTipo,
                focusNode: FocusNode(),
                nextFocus: FocusNode(),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Campo(
                tipo: TipoCampo.texto,
                titulo: 'Situação',
                controller: cSitu,
                focusNode: FocusNode(),
                enabled: false,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Campo(
                tipo: TipoCampo.data,
                titulo: 'Data',
                controller: cData,
                focusNode: FocusNode(),
                nextFocus: FocusNode(),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        Row(
          children: [
            Expanded(
              child: Campo(
                tipo: TipoCampo.inteiro,
                titulo: 'Tit',
                controller: cTit,
                focusNode: FocusNode(),
                nextFocus: FocusNode(),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Campo(
                tipo: TipoCampo.texto,
                titulo: 'Nome',
                controller: cTitNome,
                focusNode: FocusNode(),
                enabled: false,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        Row(
          children: [
            Expanded(
              child: Campo(
                tipo: TipoCampo.inteiro,
                titulo: 'Equip',
                controller: cEqp,
                focusNode: FocusNode(),
                nextFocus: FocusNode(),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Campo(
                tipo: TipoCampo.texto,
                titulo: 'Descrição',
                controller: cEqpDesc,
                focusNode: FocusNode(),
                enabled: false,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Campo(
                tipo: TipoCampo.double,
                titulo: 'HT/KM',
                controller: cHtKm,
                focusNode: FocusNode(),
                nextFocus: FocusNode(),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        Campo(
          tipo: TipoCampo.texto,
          titulo: 'Observação',
          controller: cObs,
          focusNode: FocusNode(),
        ),
      ],
    );
  }

  Widget _buildGridItens() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Itens", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        ...List.generate(itens.length, (i) {
          return Row(
            children: [
              _cell(itens[i][0], itensFocus[i][0], 60),
              const SizedBox(width: 4),
              _cell(itens[i][1], itensFocus[i][1], 220),
              const SizedBox(width: 4),
              _cell(
                itens[i][2],
                itensFocus[i][2],
                80,
                onChanged: (_) => recalcular(),
              ),
              const SizedBox(width: 4),
              _cell(
                itens[i][3],
                itensFocus[i][3],
                100,
                onChanged: (_) => recalcular(),
              ),
              const SizedBox(width: 4),
              _cell(itens[i][4], itensFocus[i][4], 100, readOnly: true),
            ],
          );
        }),
        const SizedBox(height: 6),
        ElevatedButton(
          onPressed: () {
            setState(() => _addItem());
          },
          child: const Text("Adicionar Item"),
        ),
      ],
    );
  }

  Widget _buildGridParcelas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Parcelas", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        ...List.generate(parcelas.length, (i) {
          return Row(
            children: [
              _cell(parcelas[i][0], parcelasFocus[i][0], 60),
              const SizedBox(width: 4),
              _cell(parcelas[i][1], parcelasFocus[i][1], 120),
              const SizedBox(width: 4),
              _cell(
                parcelas[i][2],
                parcelasFocus[i][2],
                120,
                onChanged: (_) => recalcular(),
              ),
            ],
          );
        }),
        const SizedBox(height: 6),
        ElevatedButton(
          onPressed: () {
            setState(() => _addParcela());
          },
          child: const Text("Adicionar Parcela"),
        ),
      ],
    );
  }

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

  Widget _buildBotoes() {
    return BotoesFormulario(
      inclusao: inclusao,
      bloqueado: isOS,
      habilitado: podeGravar,
      onGravar: _gravar,
      onExcluir: _excluir,
      onCancelar: widget.onClose,
    );
  }

  Future<void> _gravar() async {
    if (!podeGravar) return;

    List<Map<String, dynamic>> listaItens = [];
    List<Map<String, dynamic>> listaParcelas = [];

    for (int i = 0; i < itens.length; i++) {
      var r = itens[i];

      listaItens.add({
        "ipr_his": int.tryParse(r[0].text) ?? 0,
        "ipr_qtd": double.tryParse(r[2].text.replaceAll(',', '.')) ?? 0,
        "ipr_vlunit": double.tryParse(r[3].text.replaceAll(',', '.')) ?? 0,
        "ipr_vltoti": double.tryParse(r[4].text.replaceAll(',', '.')) ?? 0,
      });
    }

    for (int i = 0; i < parcelas.length; i++) {
      var r = parcelas[i];

      listaParcelas.add({
        "ppr_dtv": Campo.dataToPg(r[1].text),
        "ppr_vlpc": double.tryParse(r[2].text.replaceAll(',', '.')) ?? 0,
      });
    }

    final cabecalho = {
      "apr_tipo": cTipo.text,
      "apr_situ": cSitu.text,
      "apr_data": Campo.dataToPg(cData.text),
      "apr_tit": int.tryParse(cTit.text) ?? 0,
      "apr_eqp": int.tryParse(cEqp.text) ?? 0,
      "apr_htkm": double.tryParse(cHtKm.text.replaceAll(',', '.')) ?? 0,
      "apr_obs": cObs.text,
      "apr_vltot": totalItens,
    };

    bool quitarTotal = cSitu.text == "Quitado";

    if (inclusao) {
      await service.add(
        cabecalho: cabecalho,
        itens: listaItens,
        parcelas: listaParcelas,
        quitarTotal: quitarTotal,
      );
    } else {
      await service.update(
        apr_tr: int.parse(cTr.text),
        cabecalho: cabecalho,
        itens: listaItens,
        parcelas: listaParcelas,
        quitarTotal: quitarTotal,
      );
    }

    widget.onClose();
  }

  Future<void> _excluir() async {
    if (cTr.text.isEmpty) return;
    await service.delete(int.parse(cTr.text));
    widget.onClose();
  }
}
