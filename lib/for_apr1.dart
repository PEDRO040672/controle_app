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
  bool bloqueado = false;

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

  // ================= LISTAS =================
  List<Cadipr> itens = [];
  List<Cadppr> parcelas = [];

  double totalItens = 0;
  double totalParcelas = 0;

  bool get isOS => cTipo.text == "OS";

  @override
  void initState() {
    super.initState();
    if (widget.aprTr != null) {
      inclusao = false;
      carregar(widget.aprTr!);
    }
  }

  Future<void> carregar(int id) async {
    final cad = await service.getById(id);
    if (cad == null) return;

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

    itens = List.from(cad.itens);
    parcelas = List.from(cad.parcelas);

    recalcular();
  }

  // ================= CALCULOS =================
  void recalcular() {
    totalItens = 0;
    totalParcelas = 0;

    for (var i in itens) {
      totalItens += i.ipr_vltoti;
    }

    for (var p in parcelas) {
      totalParcelas += p.ppr_vlpc;
    }

    cTotal.text = Campo.doubleText(totalItens, '999.999,99');

    atualizarSituacao();
    setState(() {});
  }

  void atualizarSituacao() {
    if (parcelas.isEmpty) {
      cSitu.text = "Ñ Quitado";
      return;
    }

    double pago = 0;
    for (var p in parcelas) {
      pago += p.ppr_vlpc;
    }

    if (pago == 0) {
      cSitu.text = "Ñ Quitado";
    } else if (pago < totalItens) {
      cSitu.text = "Parcial";
    } else {
      cSitu.text = "Quitado";
    }
  }

  bool get podeGravar => totalItens == totalParcelas;

  // ================= CRUD =================
  Future<void> gravar() async {
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
      itens: itens,
      parcelas: parcelas,
    );

    if (inclusao) {
      await service.add(cad);
    } else {
      await service.update(cad);
    }

    widget.onClose();
  }

  // ================= UI =================
  @override
  Widget buildBody(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCabecalho(),
        const SizedBox(height: 20),
        _buildGridItens(),
        const SizedBox(height: 20),
        _buildGridParcelas(),
        const SizedBox(height: 20),
        _buildTotais(),
        const SizedBox(height: 20),
        _buildBotoes(),
      ],
    );
  }

  Widget _buildCabecalho() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
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
          enabled: inclusao,
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
          titulo: 'Equip',
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
          titulo: 'Obs',
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

  Widget _buildGridItens() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Itens", style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(
          height: 200,
          child: ListView.builder(
            itemCount: itens.length,
            itemBuilder: (_, i) {
              final it = itens[i];
              return ListTile(
                dense: true,
                title: Text("Item ${it.ipr_it} - ${it.his_desc ?? ''}"),
                trailing: Text(Campo.doubleText(it.ipr_vltoti, '999.999,99')),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGridParcelas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Parcelas", style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(
          height: 200,
          child: ListView.builder(
            itemCount: parcelas.length,
            itemBuilder: (_, i) {
              final p = parcelas[i];
              return ListTile(
                dense: true,
                title: Text("Parc ${p.ppr_pc}"),
                trailing: Text(Campo.doubleText(p.ppr_vlpc, '999.999,99')),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTotais() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Total Itens: ${Campo.doubleText(totalItens, '999.999,99')}"),
        Text(
          "Total Parcelas: ${Campo.doubleText(totalParcelas, '999.999,99')}",
        ),
        Text(
          "Diferença: ${Campo.doubleText(totalItens - totalParcelas, '999.999,99')}",
        ),
      ],
    );
  }

  Widget _buildBotoes() {
    return BotoesFormulario(
      habilitado: !podeGravar,
      inclusao: inclusao,
      bloqueado: isOS,
      onGravar: gravar,
      onExcluir: () async {},
      onCancelar: widget.onClose,
    );
  }
}
