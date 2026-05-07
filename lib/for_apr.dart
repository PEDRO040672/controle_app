import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'base_form.dart';
import '../widgets/msg.dart';
import '../widgets/campo.dart';
import '../widgets/botoes.dart';
import '../models/cadapr_models.dart';
import '../services/cadtit_services.dart';
import '../services/cadeqp_services.dart';
import '../services/cadhis_services.dart';
import '../services/cadapr_services.dart';
import 'con_apr.dart';
import 'con_tit.dart';
import 'con_eqp.dart';
import 'con_his.dart';

class ForAprPage extends BaseFormPage {
  final int? aprTr;

  const ForAprPage({super.key, required super.onClose, this.aprTr})
    : super(titulo: 'A Pagar / A Receber');

  @override
  State<ForAprPage> createState() => _ForAprState();
}

class _ForAprState extends BaseFormState<ForAprPage> {
  final CadaprServices _aprServices = CadaprServices();
  final CadtitServices _titServices = CadtitServices();
  final CadeqpServices _eqpServices = CadeqpServices();
  final CadhisServices _hisServices = CadhisServices();

  // ================= CABEÇALHO =================
  final _apr_trController = TextEditingController();
  final _apr_tipoController = TextEditingController();
  final _apr_situController = TextEditingController();
  final _apr_dataController = TextEditingController();
  final _apr_titController = TextEditingController();
  final _tit_nomeController = TextEditingController();
  final _apr_eqpController = TextEditingController();
  final _eqp_descController = TextEditingController();
  final _apr_htkmController = TextEditingController();
  final _apr_obsController = TextEditingController();
  final _apr_vltotController = TextEditingController();

  final _apr_trFocus = FocusNode();
  final _apr_tipoFocus = FocusNode();
  final _apr_situFocus = FocusNode();
  final _apr_dataFocus = FocusNode();
  final _apr_titFocus = FocusNode();
  final _tit_nomeFocus = FocusNode();
  final _apr_eqpFocus = FocusNode();
  final _eqp_descFocus = FocusNode();
  final _apr_htkmFocus = FocusNode();
  final _apr_obsFocus = FocusNode();
  final _apr_vltotFocus = FocusNode();

  final _gravarFocus = FocusNode();
  bool _inclusao = true;
  bool _habilitado = true;
  bool _situ_blq = false;
  bool _carregando = false;

  // ================= GRID =================
  final List<List<TextEditingController>> itensController = [];
  final List<List<FocusNode>> itensFocus = [];

  final List<List<TextEditingController>> parcelasController = [];
  final List<List<FocusNode>> parcelasFocus = [];

  double totalItens = 0;
  double totalParcelas = 0;

  //===============================================================
  @override
  void initState() {
    super.initState();
    if (widget.aprTr != null) {
      _inclusao = false;
      _carregarCadapr();
    } else {
      _addItem();
      _addParcela();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _apr_trFocus.requestFocus();
    });
  }

  //===============================================================
  // -------------[ Carregar CADAPR ]------------------------------
  //===============================================================
  Future<void> _carregarCadapr() async {
    final codigo = int.tryParse(_apr_trController.text) ?? 0;
    if (codigo <= 0) {
      setState(() {
        _inclusao = true;
        _habilitado = false;
        _situ_blq = false;
        _limparCampos();
        _apr_tipoController.text = "A_Pagar";
        _apr_situController.text = "Ñ Quitado";
        _apr_dataController.text = Campo.dataFromPg(
          DateTime.now().toIso8601String().split('T')[0],
        );
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _apr_tipoFocus.requestFocus();
      });
      return;
    }
    _iniciarCarregamento();
    try {
      final cadapr = await _aprServices.getById(codigo);
      if (!mounted) return;
      if (cadapr != null) {
        setState(() {
          _inclusao = false;
          _habilitado = false;
          final cad = Cadapr.fromJson({
            ...cadapr['cabecalho'],
            "itens": cadapr['itens'],
            "parcelas": cadapr['parcelas'],
          });
          _apr_trController.text = cad.apr_tr.toString();
          _apr_tipoController.text = cad.apr_tipo;
          _apr_situController.text = cad.apr_situ;
          if ((_apr_situController.text != "Ñ Quitado") ||
              (_apr_tipoController.text == "OS")) {
            _situ_blq = true;
          }
          _apr_dataController.text = Campo.dataFromPg(
            cad.apr_data.toIso8601String().split('T')[0],
          );
          _apr_titController.text = cad.apr_tit.toString();
          _tit_nomeController.text = cad.tit_nome;
          _apr_eqpController.text = cad.apr_eqp.toString();
          _eqp_descController.text = cad.eqp_desc;
          _apr_htkmController.text = Campo.doubleText(
            cad.apr_htkm,
            '999.999,9',
          );
          _apr_obsController.text = cad.apr_obs;
          _limparLinhas(); // limpar Linhas dos itens e parcelas
          for (var i in cad.itens) {
            _addItem();
            itensController.last[0].text = i.ipr_his.toString();
            itensController.last[1].text = i.his_desc ?? '';
            itensController.last[2].text = Campo.doubleText(i.ipr_qtd, '999,9');
            itensController.last[3].text = Campo.doubleText(
              i.ipr_vlunit,
              '9.999,99',
            );
          }
          for (var p in cad.parcelas) {
            _addParcela();
            parcelasController.last[0].text = Campo.dataFromPg(
              p.ppr_dtv.toIso8601String().split('T')[0],
            );
            parcelasController.last[1].text = Campo.doubleText(
              p.ppr_vlpc,
              '9.999.999,99',
            );
          }
          recalcular();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _apr_tipoFocus.requestFocus();
          });
        });
      } else {
        await MSG(context, 'Aviso', 'Registro não encontrado.', 1);
        _cancelar();
      }
    } catch (e) {
      if (!mounted) return;
      await MSG(context, 'Erro', '$e', 1);
    } finally {
      _finalizarCarregamento();
    }
  }

  //===============================================================
  void _addItem() {
    itensController.add([
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

  //===============================================================
  void _addParcela() {
    parcelasController.add([TextEditingController(), TextEditingController()]);
    parcelasFocus.add([FocusNode(), FocusNode()]);
  }

  //===============================================================
  void recalcular() {
    totalItens = 0;
    totalParcelas = 0;
    for (var r in itensController) {
      double qtd = Campo.textDouble(r[2].text);
      double vl = Campo.textDouble(r[3].text);
      double tot = qtd * vl;
      r[4].text = Campo.doubleText(tot, '9.999.999,99');

      totalItens += tot;
    }
    for (var r in parcelasController) {
      totalParcelas += Campo.textDouble(r[1].text);
    }
    _apr_vltotController.text = Campo.doubleText(totalItens, '9.999.999,99');

    setState(() {});
  }

  //===============================================================
  bool get podeGravar =>
      (totalItens > 0) &&
      (totalParcelas > 0) &&
      ((totalItens - totalParcelas).abs() < 0.005);

  //===============================================================
  @override
  Widget buildBody(BuildContext context) {
    return Stack(
      children: [
        Focus(
          autofocus: true,
          onKeyEvent: (node, event) {
            if (event is KeyDownEvent) {
              if (event.logicalKey == LogicalKeyboardKey.f2) {
                if (_habilitado && _apr_trFocus.hasFocus) {
                  _abrirConsulta();
                  return KeyEventResult.handled;
                }
                if (!_habilitado && _apr_titFocus.hasFocus) {
                  _abrirConsultaCadtit();
                  return KeyEventResult.handled;
                }
                if (!_habilitado && _apr_eqpFocus.hasFocus) {
                  _abrirConsultaCadeqp();
                  return KeyEventResult.handled;
                }
              }
              if (event.logicalKey == LogicalKeyboardKey.escape) {
                onEscapePressed();
                return KeyEventResult.handled;
              }
            }
            return KeyEventResult.ignored;
          },
          child: FocusTraversalGroup(
            policy: OrderedTraversalPolicy(),
            child: Column(
              children: [
                _buildCabecalho(),
                const SizedBox(height: 12),
                _buildGridItens(),
                const SizedBox(height: 12),
                _buildGridParcelas(),
                const SizedBox(height: 12),
                _buildTotais(),
                const SizedBox(height: 12),
                BotoesFormulario(
                  onGravar: (!_habilitado && podeGravar && !_situ_blq)
                      ? _gravar
                      : null,
                  onExcluir: (!_habilitado && !_inclusao && !_situ_blq)
                      ? _excluir
                      : null,
                  onCancelar: !_habilitado ? _cancelar : null,
                  focusGravar: _gravarFocus,
                ),
              ],
            ),
          ),
        ),

        // OVERLAY DE LOADING
        if (_carregando)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.2),
              child: const Center(
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
              ),
            ),
          ),
      ],
    );
  }

  //===============================================================
  Widget _buildCabecalho() {
    return Column(
      children: [
        Row(
          children: [
            Campo(
              tipo: TipoCampo.inteiro,
              titulo: 'TR [2c/F2]',
              controller: _apr_trController,
              focusNode: _apr_trFocus,
              nextFocus: _apr_tipoFocus,
              tamanho: 6,
              enabled: _habilitado,
              onDoubleTap: () {
                _abrirConsulta();
              },
              onSubmitted: () async {
                await _carregarCadapr();
                return true;
              },
            ),
            const Spacer(),
            Campo(
              tipo: TipoCampo.lista,
              titulo: 'Tipo',
              controller: _apr_tipoController,
              lista: 'OS,A_Pagar,A_Receber',
              focusNode: _apr_tipoFocus,
              nextFocus: _apr_dataFocus,
              enabled: !_habilitado && !_situ_blq,
              onSubmitted: _valid_apr_tipo,
            ),
          ],
        ),

        const SizedBox(height: 10),
        Row(
          children: [
            Campo(
              tipo: TipoCampo.lista,
              titulo: 'Situação',
              controller: _apr_situController,
              lista: 'Ñ Quitado,Quitado,Parcial',
              focusNode: _apr_situFocus,
              //nextFocus: _apr_dataFocus,
              enabled: false,
            ),
            const Spacer(),
            Campo(
              tipo: TipoCampo.data,
              titulo: 'Data',
              controller: _apr_dataController,
              focusNode: _apr_dataFocus,
              nextFocus: _apr_titFocus,
              enabled: !_habilitado && !_situ_blq,
              onSubmitted: _valid_apr_data,
            ),
          ],
        ),

        const SizedBox(height: 10),
        Row(
          children: [
            Campo(
              tipo: TipoCampo.inteiro,
              titulo: 'Titular',
              controller: _apr_titController,
              focusNode: _apr_titFocus,
              nextFocus: _apr_eqpFocus,
              tamanho: 5,
              enabled: !_habilitado && !_situ_blq,
              onDoubleTap: () {
                _abrirConsultaCadtit();
              },
              onSubmitted: _carregarCadtit,
            ),
            SizedBox(width: 5),
            Expanded(
              child: Campo(
                tipo: TipoCampo.texto,
                titulo: '',
                controller: _tit_nomeController,
                focusNode: _tit_nomeFocus,
                tamanho: 50,
                enabled: false,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),
        Row(
          children: [
            Campo(
              tipo: TipoCampo.inteiro,
              titulo: 'Eqpto',
              controller: _apr_eqpController,
              focusNode: _apr_eqpFocus,
              nextFocus: _apr_htkmFocus,
              tamanho: 5,
              enabled: !_habilitado && !_situ_blq,
              onDoubleTap: () {
                _abrirConsultaCadeqp();
              },
              onSubmitted: _carregarCadeqp,
            ),
            SizedBox(width: 5),
            Expanded(
              child: Campo(
                tipo: TipoCampo.texto,
                titulo: '',
                controller: _eqp_descController,
                focusNode: _eqp_descFocus,
                tamanho: 50,
                enabled: false,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),
        Row(
          children: [
            Campo(
              tipo: TipoCampo.double,
              titulo: 'HT/KM',
              controller: _apr_htkmController,
              focusNode: _apr_htkmFocus,
              mascara: '999.999,9',
              nextFocus: _apr_obsFocus,
              enabled: !_habilitado && !_situ_blq,
              onSubmitted: _valid_apr_htkm,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Campo(
                tipo: TipoCampo.texto,
                titulo: 'Observação',
                controller: _apr_obsController,
                focusNode: _apr_obsFocus,
                nextFocus: itensFocus.isNotEmpty ? itensFocus[0][0] : null,
                tamanho: 50,
                enabled: !_habilitado && !_situ_blq,
              ),
            ),
          ],
        ),
      ],
    );
  }

  //===============================================================
  Widget _buildGridItens() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Itens", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),

        ...List.generate(itensController.length, (i) {
          return Wrap(
            spacing: 5,
            runSpacing: 5,
            children: [
              Campo(
                tipo: TipoCampo.inteiro,
                titulo: i == 0 ? 'Histórico' : '',
                controller: itensController[i][0],
                focusNode: itensFocus[i][0],
                nextFocus: itensFocus[i][1],
                tamanho: 4,
                enabled: !_habilitado && !_situ_blq,
                onDoubleTap: () {
                  _abrirConsultaCadhis(i);
                },
                onSubmitted: () => _carregarCadhis(i),
              ),

              Campo(
                tipo: TipoCampo.texto,
                titulo: i == 0 ? 'Descrição' : '',
                controller: itensController[i][1],
                focusNode: itensFocus[i][1],
                tamanho: 10,
                enabled: false,
              ),

              Campo(
                tipo: TipoCampo.double,
                titulo: i == 0 ? 'Qtda' : '',
                controller: itensController[i][2],
                focusNode: itensFocus[i][2],
                nextFocus: itensFocus[i][3],
                mascara: '999,9',
                onChanged: (_) => recalcular(),
                enabled: !_habilitado && !_situ_blq,
              ),

              Campo(
                tipo: TipoCampo.double,
                titulo: i == 0 ? 'Vl. Unitário' : '',
                controller: itensController[i][3],
                focusNode: itensFocus[i][3],
                nextFocus: parcelasFocus[0][0],
                mascara: '99.999,99',
                onChanged: (_) => recalcular(),
                onSubmitted: _inclusao
                    ? () async {
                        parcelasController[0][0].text = Campo.dataFromPg(
                          DateTime.now().toIso8601String().split('T')[0],
                        );
                        parcelasController[0][1].text = Campo.doubleText(
                          totalItens,
                          '9.999.999,99',
                        );
                        recalcular();
                        return true;
                      }
                    : null,
                enabled: !_habilitado && !_situ_blq,
              ),

              Campo(
                tipo: TipoCampo.double,
                titulo: i == 0 ? 'V. Tot. Item' : '',
                controller: itensController[i][4],
                focusNode: itensFocus[i][4],
                mascara: '9.999.999,99',
                enabled: false,
              ),
              if (!_situ_blq)
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.delete, size: 18),
                  onPressed: (!_habilitado && !_situ_blq)
                      ? () => _removerItem(i)
                      : null,
                ),
            ],
          );
        }),

        const SizedBox(height: 6),

        ElevatedButton(
          onPressed: (!_habilitado && !_situ_blq)
              ? () {
                  setState(() => _addItem());
                }
              : null,
          child: const Text("+ Item"),
        ),
      ],
    );
  }

  //===============================================================
  Widget _buildGridParcelas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Parcelas", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),

        ...List.generate(parcelasController.length, (i) {
          return Wrap(
            spacing: 5,
            runSpacing: 5,
            children: [
              // Data vencimento
              Campo(
                tipo: TipoCampo.data,
                titulo: i == 0 ? 'Data Venc.' : '',
                controller: parcelasController[i][0],
                focusNode: parcelasFocus[i][0],
                nextFocus: parcelasFocus[i][1],
                enabled: !_habilitado && !_situ_blq,
                onSubmitted: () => _valid_ppr_data(i),
              ),

              // Valor parcela
              Campo(
                tipo: TipoCampo.double,
                titulo: i == 0 ? 'Valor Parcela' : '',
                controller: parcelasController[i][1],
                focusNode: parcelasFocus[i][1],
                mascara: '9.999.999,99',
                onChanged: (_) => recalcular(),
                nextFocus: _gravarFocus,
                enabled: !_habilitado && !_situ_blq,
              ),
              if (!_situ_blq)
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.delete, size: 18),
                  onPressed: (!_habilitado && !_situ_blq)
                      ? () => _removerParcela(i)
                      : null,
                ),
            ],
          );
        }),
        const SizedBox(height: 6),
        Wrap(
          spacing: 5,
          runSpacing: 5,
          children: [
            ElevatedButton(
              onPressed: (!_habilitado && !_situ_blq)
                  ? () {
                      setState(() => _addParcela());
                    }
                  : null,
              child: const Text("+ Parcela"),
            ),
            ElevatedButton(
              onPressed: (!_habilitado && !_situ_blq && podeGravar)
                  ? () {
                      _apr_situController.text = "Quitado";
                      _gravar();
                    }
                  : null,
              child: const Text("Quitar Tudo"),
            ),
          ],
        ),
      ],
    );
  }

  //===============================================================
  Widget _buildTotais() {
    return Row(
      children: [
        Expanded(
          child: Text(
            "Total Itens:\n${Campo.doubleText(totalItens, '9.999.999,99')}",
            textAlign: TextAlign.left,
          ),
        ),
        Expanded(
          child: Text(
            "Total Parcelas:\n${Campo.doubleText(totalParcelas, '9.999.999,99')}",
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: Text(
            "Diferença:\n${Campo.doubleText((totalItens - totalParcelas), '9.999.999,99')}",
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // GRAVAR
  // ============================================================
  Future<void> _gravar() async {
    if (!await _valid_apr_tipo()) return;
    if (!await _valid_apr_data()) return;
    if (!await _valid_apr_htkm()) return;

    if (!podeGravar) {
      await MSG(
        context,
        'Aviso',
        'Não pode gravar, pois ha fiferenças nos valores.',
        1,
      );
      return;
    }

    //--------[ Se PASSOU nas Validações, CONTINUA ]------------
    List<Map<String, dynamic>> listaItens = [];
    List<Map<String, dynamic>> listaParcelas = [];
    for (int i = 0; i < itensController.length; i++) {
      var r = itensController[i];
      listaItens.add({
        "ipr_his": int.parse(r[0].text),
        "ipr_qtd": Campo.textDouble(r[2].text),
        "ipr_vlunit": Campo.textDouble(r[3].text),
        "ipr_vltoti": Campo.textDouble(r[4].text),
      });
    }
    for (int i = 0; i < parcelasController.length; i++) {
      var r = parcelasController[i];
      listaParcelas.add({
        "ppr_dtv": Campo.dataToPg(r[0].text),
        "ppr_vlpc": Campo.textDouble(r[1].text),
      });
    }
    final cabecalho = {
      "apr_tipo": _apr_tipoController.text,
      "apr_situ": _apr_situController.text,
      "apr_data": Campo.dataToPg(_apr_dataController.text),
      "apr_tit": int.parse(_apr_titController.text),
      "apr_eqp": int.parse(_apr_eqpController.text),
      "apr_htkm": Campo.textDouble(_apr_htkmController.text),
      "apr_obs": _apr_obsController.text,
      "apr_vltot": totalItens,
    };
    //bool quitarTotal = _apr_situController.text == "Quitado";
    _iniciarCarregamento();
    try {
      if (_inclusao) {
        await _aprServices.add(
          cabecalho: cabecalho,
          itens: listaItens,
          parcelas: listaParcelas,
        );
      } else {
        await _aprServices.update(
          apr_tr: int.parse(_apr_trController.text),
          cabecalho: cabecalho,
          itens: listaItens,
          parcelas: listaParcelas,
        );
      }
      if (!mounted) return;
      await MSG(context, 'Aviso', 'Registro gravado com sucesso.', 1);
      //_cancelar();
    } catch (e) {
      if (!mounted) return;
      await MSG(context, 'Erro', 'Registro NÃO gravado: $e', 1);
    } finally {
      _cancelar();
      _finalizarCarregamento();
    }
  }

  // ============================================================
  // EXCLUIR
  // ============================================================
  Future<void> _excluir() async {
    final codigo = int.tryParse(_apr_trController.text) ?? 0;
    if (codigo <= 0) return;
    _iniciarCarregamento();
    try {
      await _aprServices.delete(codigo);
      if (!mounted) return;
      await MSG(context, 'Aviso', 'Registro excluído com sucesso.', 1);
    } catch (e) {
      if (!mounted) return;
      await MSG(context, 'Erro', 'Erro ao excluir: $e', 1);
    } finally {
      _cancelar();
      _finalizarCarregamento();
    }
  }

  // ============================================================
  // CONSULTA
  // ============================================================
  Future<void> _abrirConsulta() async {
    FocusScope.of(context).unfocus();
    final int? idSelecionado = await ConsultaCadapr.abrir(context);
    if (idSelecionado != null) {
      _apr_trController.text = idSelecionado.toString();
      await _carregarCadapr();
    }
  }

  // ============================================================
  // CONSULTA  CADTIT
  // ============================================================
  Future<void> _abrirConsultaCadtit() async {
    FocusScope.of(context).unfocus();
    final int? idSelecionado = await ConsultaCadtit.abrir(context);
    if (idSelecionado != null) {
      _apr_titController.text = idSelecionado.toString();
      await _carregarCadtit();
    }
  }

  // ============================================================
  // CONSULTA  CADEQP
  // ============================================================
  Future<void> _abrirConsultaCadeqp() async {
    FocusScope.of(context).unfocus();
    final int? idSelecionado = await ConsultaCadeqp.abrir(context);
    if (idSelecionado != null) {
      _apr_eqpController.text = idSelecionado.toString();
      await _carregarCadeqp();
    }
  }

  // ============================================================
  // CONSULTA  CADHIS
  // ============================================================
  Future<void> _abrirConsultaCadhis(int i) async {
    FocusScope.of(context).unfocus();
    final int? idSelecionado = await ConsultaCadhis.abrir(context);
    if (idSelecionado != null) {
      itensController[i][0].text = idSelecionado.toString();
      await _carregarCadhis(i);
    }
  }

  // ============================================================
  // CARREGAR CADTIT
  // ============================================================
  Future<bool> _carregarCadtit() async {
    final codigo = int.tryParse(_apr_titController.text) ?? 0;
    if (codigo <= 0) {
      setState(() {
        _apr_titController.clear();
        _tit_nomeController.clear();
        _apr_titFocus.requestFocus();
      });
      _abrirConsultaCadtit();
      return false;
    }
    _iniciarCarregamento();
    try {
      final cadtit = await _titServices.getById(codigo);
      if (!mounted) {
        setState(() {
          _apr_titController.clear();
          _tit_nomeController.clear();
          _apr_titFocus.requestFocus();
        });
        return false;
      }
      if (cadtit != null) {
        _tit_nomeController.text = cadtit.tit_nome;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _apr_eqpFocus.requestFocus();
        });
      } else {
        await MSG(context, 'Aviso', 'Titular não encontrado.', 1);
        setState(() {
          _apr_titController.clear();
          _tit_nomeController.clear();
          _apr_titFocus.requestFocus();
        });
        return false;
      }
    } catch (e) {
      if (!mounted) return false;
      await MSG(context, 'Erro', '$e', 1);
    } finally {
      _finalizarCarregamento();
    }
    return true;
  }

  // ============================================================
  // CARREGAR CADEQP
  // ============================================================
  Future<bool> _carregarCadeqp() async {
    final codigo = int.tryParse(_apr_eqpController.text) ?? 0;
    if (codigo <= 0) {
      setState(() {
        _apr_eqpController.clear();
        _eqp_descController.clear();
        _apr_eqpFocus.requestFocus();
      });
      _abrirConsultaCadeqp();
      return false;
    }
    _iniciarCarregamento();
    try {
      final cadeqp = await _eqpServices.getById(codigo);
      if (!mounted) {
        setState(() {
          _apr_eqpController.clear();
          _eqp_descController.clear();
          _apr_eqpFocus.requestFocus();
        });
        return false;
      }
      if (cadeqp != null) {
        _eqp_descController.text = cadeqp.eqp_desc;
        if (_inclusao) {
          _apr_htkmController.text = Campo.doubleText(
            cadeqp.eqp_htkm,
            '999.999,9',
          );
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _apr_htkmFocus.requestFocus();
        });
      } else {
        await MSG(context, 'Aviso', 'Equipamento não encontrado.', 1);
        setState(() {
          _apr_eqpController.clear();
          _eqp_descController.clear();
          _apr_eqpFocus.requestFocus();
        });
        return false;
      }
    } catch (e) {
      if (!mounted) return false;
      await MSG(context, 'Erro', '$e', 1);
    } finally {
      _finalizarCarregamento();
    }
    return true;
  }

  // ============================================================
  // CARREGAR CADHIS
  // ============================================================
  Future<bool> _carregarCadhis(int i) async {
    final codigo = int.tryParse(itensController[i][0].text) ?? 0;
    if (codigo <= 0) {
      setState(() {
        itensController[i][0].clear();
        itensController[i][1].clear();
        itensFocus[i][0].requestFocus();
      });
      _abrirConsultaCadhis(i);
      return false;
    }
    _iniciarCarregamento();
    try {
      final cadhis = await _hisServices.getById(codigo);
      if (!mounted) {
        setState(() {
          itensController[i][0].clear();
          itensController[i][1].clear();
          itensFocus[i][0].requestFocus();
        });
        return false;
      }
      if (cadhis != null) {
        itensController[i][1].text = cadhis.his_desc;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) itensFocus[i][2].requestFocus();
        });
      } else {
        await MSG(context, 'Aviso', 'Histórico não encontrado.', 1);
        setState(() {
          itensController[i][0].clear();
          itensController[i][1].clear();
          itensFocus[i][0].requestFocus();
        });
        return false;
      }
    } catch (e) {
      if (!mounted) return false;
      await MSG(context, 'Erro', '$e', 1);
    } finally {
      _finalizarCarregamento();
    }
    return true;
  }

  // ============================================================
  // LOADING
  // ============================================================
  void _iniciarCarregamento() {
    setState(() => _carregando = true);
  }

  void _finalizarCarregamento() {
    if (mounted) {
      setState(() => _carregando = false);
    }
  }

  // ============================================================
  // LIMPAR
  // ============================================================
  void _limparCampos() {
    _apr_trController.clear();
    _apr_tipoController.clear();
    _apr_situController.clear();
    _apr_dataController.clear();
    _apr_titController.clear();
    _tit_nomeController.clear();
    _apr_eqpController.clear();
    _eqp_descController.clear();
    _apr_htkmController.clear();
    _apr_obsController.clear();
    _apr_vltotController.clear();
    _limparLinhas(); // limpar Linhas
    _addItem(); // recria 1 linha itens
    _addParcela(); // recria 1 linha parcelas
  }

  // ============================================================
  // Limpar Linhas dos Itens e Parcelas
  // ============================================================
  void _limparLinhas() {
    // limpar controllers itens
    for (var linha in itensController) {
      for (var c in linha) {
        c.dispose();
      }
    }
    // limpar focus itens
    for (var linha in itensFocus) {
      for (var f in linha) {
        f.dispose();
      }
    }
    itensController.clear();
    itensFocus.clear();
    // limpar controllers parcelas
    for (var linha in parcelasController) {
      for (var c in linha) {
        c.dispose();
      }
    }
    // limpar focus parcelas
    for (var linha in parcelasFocus) {
      for (var f in linha) {
        f.dispose();
      }
    }
    parcelasController.clear();
    parcelasFocus.clear();
    totalItens = 0;
    totalParcelas = 0;
  }

  // ============================================================
  // CANCELAR
  // ============================================================
  void _cancelar() {
    FocusScope.of(context).unfocus();
    setState(() {
      _inclusao = true;
      _habilitado = true;
      _situ_blq = false;
      _limparCampos();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _apr_trFocus.requestFocus();
    });
  }

  //========================[ _valid_apr_tipo ]===========
  Future<bool> _valid_apr_tipo() async {
    if (_apr_tipoController.text == "OS" || _apr_tipoController.text == "") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tipo OS, deve ser A Pagar ou A Receber.'),
          duration: Duration(seconds: 2),
        ),
      );
      _apr_tipoFocus.requestFocus(); // volta foco no campo
      return false;
    }
    return true;
  }

  //========================[ _valid_apr_data ]===========
  Future<bool> _valid_apr_data() async {
    if (!Campo.validaData(_apr_dataController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data inválida.'),
          duration: Duration(seconds: 2),
        ),
      );
      _apr_dataFocus.requestFocus(); // volta foco no campo
      return false;
    }
    return true;
  }

  //========================[ _valid_os_HTKM ]===========
  Future<bool> _valid_apr_htkm() async {
    final valor = Campo.textDouble(_apr_htkmController.text);
    if (valor <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('O campo HT/KM deve ser maior que zero.'),
          duration: Duration(seconds: 2),
        ),
      );
      _apr_htkmFocus.requestFocus(); // volta foco no campo
      return false;
    }
    return true;
  }

  //========================[ _valid_ppr_data ]===========
  Future<bool> _valid_ppr_data(int i) async {
    if (!Campo.validaData(parcelasController[i][0].text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data inválida.'),
          duration: Duration(seconds: 2),
        ),
      );
      parcelasFocus[i][0].requestFocus(); // volta foco no campo
      return false;
    }
    return true;
  }

  @override
  void onEscapePressed() {
    if (_habilitado) {
      widget.onClose();
    } else {
      _cancelar();
    }
  }

  //========================[ Remover Item ]===========
  void _removerItem(int i) {
    if (itensController.length == 1) return;
    for (var c in itensController[i]) {
      c.dispose();
    }
    for (var f in itensFocus[i]) {
      f.dispose();
    }
    itensController.removeAt(i);
    itensFocus.removeAt(i);
    recalcular();
    setState(() {});
  }

  //========================[ Remover Parcelas ]===========
  void _removerParcela(int i) {
    if (parcelasController.length == 1) return;
    for (var c in parcelasController[i]) {
      c.dispose();
    }
    for (var f in parcelasFocus[i]) {
      f.dispose();
    }
    parcelasController.removeAt(i);
    parcelasFocus.removeAt(i);
    recalcular();
    setState(() {});
  }

  //========================[ disponse ]===========
  @override
  void dispose() {
    // cabecalho controllers
    _apr_trController.dispose();
    _apr_tipoController.dispose();
    _apr_situController.dispose();
    _apr_dataController.dispose();
    _apr_titController.dispose();
    _tit_nomeController.dispose();
    _apr_eqpController.dispose();
    _eqp_descController.dispose();
    _apr_htkmController.dispose();
    _apr_obsController.dispose();
    _apr_vltotController.dispose();

    // cabecalho focus
    _apr_trFocus.dispose();
    _apr_tipoFocus.dispose();
    _apr_situFocus.dispose();
    _apr_dataFocus.dispose();
    _apr_titFocus.dispose();
    _tit_nomeFocus.dispose();
    _apr_eqpFocus.dispose();
    _eqp_descFocus.dispose();
    _apr_htkmFocus.dispose();
    _apr_obsFocus.dispose();
    _apr_vltotFocus.dispose();

    _gravarFocus.dispose();

    _limparLinhas();
    super.dispose();
  }
}
