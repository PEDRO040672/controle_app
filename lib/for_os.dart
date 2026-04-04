import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'widgets/botoes.dart';
import '../widgets/campo.dart';
import '../widgets/msg.dart';
import '../models/cados_models.dart';
import 'services/cados_services.dart';
import 'services/cadhis_services.dart';
import 'services/cadcid_services.dart';
import 'services/cadtit_services.dart';
import 'services/cadeqp_services.dart';
import 'services/cadope_services.dart';
import 'base_form.dart';
import 'con_os.dart';
import 'con_his.dart';
import 'con_cid.dart';
import 'con_tit.dart';
import 'con_eqp.dart';
import 'con_ope.dart';

class ForOsPage extends BaseFormPage {
  const ForOsPage({super.key, required super.onClose})
    : super(titulo: 'Ordens de Serviços');

  @override
  State<ForOsPage> createState() => _ForOsState();
}

class _ForOsState extends BaseFormState<ForOsPage> {
  final CadosServices _osServices = CadosServices();
  final CadhisServices _hisServices = CadhisServices();
  final CadcidServices _cidServices = CadcidServices();
  final CadtitServices _titServices = CadtitServices();
  final CadeqpServices _eqpServices = CadeqpServices();
  final CadopeServices _opeServices = CadopeServices();

  final _os_trController = TextEditingController();
  final _os_situController = TextEditingController();
  final _os_dataController = TextEditingController();
  final _os_horaController = TextEditingController();
  final _os_hisController = TextEditingController();
  final _his_descController = TextEditingController();
  final _os_cidController = TextEditingController();
  final _cid_nomeController = TextEditingController();
  final _os_titController = TextEditingController();
  final _tit_nomeController = TextEditingController();
  final _os_eqpController = TextEditingController();
  final _eqp_descController = TextEditingController();
  final _os_opeController = TextEditingController();
  final _ope_nomeController = TextEditingController();
  final _os_obsController = TextEditingController();
  final _os_htkmiController = TextEditingController();
  final _os_htkmfController = TextEditingController();
  final _os_qtdController = TextEditingController();
  final _os_vlunitController = TextEditingController();
  final _os_vldescController = TextEditingController();
  final _os_vltotsController = TextEditingController();

  final _os_trFocus = FocusNode();
  final _os_situFocus = FocusNode();
  final _os_dataFocus = FocusNode();
  final _os_horaFocus = FocusNode();
  final _os_hisFocus = FocusNode();
  final _his_descFocus = FocusNode();
  final _os_cidFocus = FocusNode();
  final _cid_nomeFocus = FocusNode();
  final _os_titFocus = FocusNode();
  final _tit_nomeFocus = FocusNode();
  final _os_eqpFocus = FocusNode();
  final _eqp_descFocus = FocusNode();
  final _os_opeFocus = FocusNode();
  final _ope_nomeFocus = FocusNode();
  final _os_obsFocus = FocusNode();
  final _os_htkmiFocus = FocusNode();
  final _os_htkmfFocus = FocusNode();
  final _os_qtdFocus = FocusNode();
  final _os_vlunitFocus = FocusNode();
  final _os_vldescFocus = FocusNode();
  final _os_vltotsFocus = FocusNode();

  final _gravarFocus = FocusNode();

  bool _inclusao = true;
  bool _habilitado = true;
  bool _situ_blq = false;
  bool _carregando = false;

  String _montarTextoCompartilhar() {
    // 👇 regra da Observação
    final mostrarObs = _os_obsController.text.trim() != '';
    final obsLinha = mostrarObs
        ? 'Observação: ${_os_obsController.text}\n'
        : '';
    // 👇 regra do desconto
    final desconto = _os_vldescController.text.trim();
    final mostrarDesconto =
        desconto.isNotEmpty &&
        desconto != '0' &&
        desconto != '0,00' &&
        desconto != '0.00';
    final descontoLinha = mostrarDesconto ? 'Desconto: - $desconto\n' : '';
    return '''
ORDEM DE SERVIÇO

OS: ${_os_trController.text}
${_os_dataController.text} - ${_os_horaController.text}

Serviço: ${_his_descController.text}
Cidade: ${_cid_nomeController.text}
Eqpto: ${_eqp_descController.text}
Ope.: ${_ope_nomeController.text}
$obsLinha
Inicial: ${_os_htkmiController.text}
Final: ${_os_htkmfController.text}
Quantidade: ${_os_qtdController.text}
Vl. Unitário: ${_os_vlunitController.text}
$descontoLinha
TOTAL: R\$ ${_os_vltotsController.text}

====================
Dados para Pagamento:
PEDRO ROGÉRIO AZEVEDO
Banco BTG Pactual

Chave PIX CPF:
58887458120

TOTAL: R\$ ${_os_vltotsController.text}
''';
  }

  Future<void> _compartilhar() async {
    final texto = _montarTextoCompartilhar();
    await Clipboard.setData(ClipboardData(text: texto));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Texto copiado! Cole no WhatsApp com Ctrl + V'),
        duration: Duration(seconds: 2),
      ),
    );
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
  // botão compartilhar
  // ============================================================
  @override
  VoidCallback? buildShareAction() {
    if (_os_trController.text.isEmpty) return null;
    return _compartilhar;
  }

  // ============================================================
  // INIT
  // ============================================================
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _os_trFocus.requestFocus();
      }
    });
  }

  // ============================================================
  // LIMPAR
  // ============================================================
  void _limparCampos() {
    _os_situController.clear();
    _os_dataController.clear();
    _os_trController.clear();
    _os_horaController.clear();
    _os_hisController.clear();
    _his_descController.clear();
    _os_cidController.clear();
    _cid_nomeController.clear();
    _os_titController.clear();
    _tit_nomeController.clear();
    _os_eqpController.clear();
    _eqp_descController.clear();
    _os_opeController.clear();
    _ope_nomeController.clear();
    _os_obsController.clear();
    _os_htkmiController.clear();
    _os_htkmfController.clear();
    _os_qtdController.clear();
    _os_vlunitController.clear();
    _os_vldescController.clear();
    _os_vltotsController.clear();
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
      if (mounted) _os_trFocus.requestFocus();
    });
  }

  // ============================================================
  // ESC INTELIGENTE
  // ============================================================
  @override
  void onEscapePressed() {
    if (_habilitado) {
      widget.onClose();
    } else {
      _cancelar();
    }
  }

  // ============================================================
  // CARREGAR CADHIS
  // ============================================================
  Future<bool> _carregarCadhis() async {
    final codigo = int.tryParse(_os_hisController.text) ?? 0;
    if (codigo <= 0) {
      setState(() {
        _os_hisController.clear();
        _his_descController.clear();
        _os_hisFocus.requestFocus();
      });
      _abrirConsultaCadhis();
      return false;
    }
    _iniciarCarregamento();
    try {
      final cadhis = await _hisServices.getById(codigo);
      if (!mounted) {
        setState(() {
          _os_hisController.clear();
          _his_descController.clear();
          _os_hisFocus.requestFocus();
        });
        return false;
      }
      if (cadhis != null) {
        _his_descController.text = cadhis.his_desc;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _os_cidFocus.requestFocus();
        });
      } else {
        await MSG(context, 'Aviso', 'Histórico não encontrado.', 1);
        setState(() {
          _os_hisController.clear();
          _his_descController.clear();
          _os_hisFocus.requestFocus();
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
  // CARREGAR CADCID
  // ============================================================
  Future<bool> _carregarCadcid() async {
    final codigo = int.tryParse(_os_cidController.text) ?? 0;
    if (codigo <= 0) {
      setState(() {
        _os_cidController.clear();
        _cid_nomeController.clear();
        _os_cidFocus.requestFocus();
      });
      _abrirConsultaCadcid();
      return false;
    }
    _iniciarCarregamento();
    try {
      final cadcid = await _cidServices.getById(codigo);
      if (!mounted) {
        setState(() {
          _os_cidController.clear();
          _cid_nomeController.clear();
          _os_cidFocus.requestFocus();
        });
        return false;
      }
      if (cadcid != null) {
        _cid_nomeController.text = cadcid.cid_nome;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _os_titFocus.requestFocus();
        });
      } else {
        await MSG(context, 'Aviso', 'Cidade não encontrado.', 1);
        setState(() {
          _os_cidController.clear();
          _cid_nomeController.clear();
          _os_cidFocus.requestFocus();
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
  // CARREGAR CADTIT
  // ============================================================
  Future<bool> _carregarCadtit() async {
    final codigo = int.tryParse(_os_titController.text) ?? 0;
    if (codigo <= 0) {
      setState(() {
        _os_titController.clear();
        _tit_nomeController.clear();
        _os_titFocus.requestFocus();
      });
      _abrirConsultaCadtit();
      return false;
    }
    _iniciarCarregamento();
    try {
      final cadtit = await _titServices.getById(codigo);
      if (!mounted) {
        setState(() {
          _os_titController.clear();
          _tit_nomeController.clear();
          _os_titFocus.requestFocus();
        });
        return false;
      }
      if (cadtit != null) {
        _tit_nomeController.text = cadtit.tit_nome;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _os_eqpFocus.requestFocus();
        });
      } else {
        await MSG(context, 'Aviso', 'Titular não encontrado.', 1);
        setState(() {
          _os_titController.clear();
          _tit_nomeController.clear();
          _os_titFocus.requestFocus();
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
    final codigo = int.tryParse(_os_eqpController.text) ?? 0;
    if (codigo <= 0) {
      setState(() {
        _os_eqpController.clear();
        _eqp_descController.clear();
        _os_eqpFocus.requestFocus();
      });
      _abrirConsultaCadeqp();
      return false;
    }
    _iniciarCarregamento();
    try {
      final cadeqp = await _eqpServices.getById(codigo);
      if (!mounted) {
        setState(() {
          _os_eqpController.clear();
          _eqp_descController.clear();
          _os_eqpFocus.requestFocus();
        });
        return false;
      }
      if (cadeqp != null) {
        _eqp_descController.text = cadeqp.eqp_desc;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _os_opeFocus.requestFocus();
        });
      } else {
        await MSG(context, 'Aviso', 'Equipamento não encontrado.', 1);
        setState(() {
          _os_eqpController.clear();
          _eqp_descController.clear();
          _os_eqpFocus.requestFocus();
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
  // CARREGAR CADOPE
  // ============================================================
  Future<bool> _carregarCadope() async {
    final codigo = int.tryParse(_os_opeController.text) ?? 0;
    if (codigo <= 0) {
      setState(() {
        _os_opeController.clear();
        _ope_nomeController.clear();
        _os_opeFocus.requestFocus();
      });
      _abrirConsultaCadope();
      return false;
    }
    _iniciarCarregamento();
    try {
      final cadope = await _opeServices.getById(codigo);
      if (!mounted) {
        setState(() {
          _os_opeController.clear();
          _ope_nomeController.clear();
          _os_opeFocus.requestFocus();
        });
        return false;
      }
      if (cadope != null) {
        _ope_nomeController.text = cadope.ope_nome;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _os_obsFocus.requestFocus();
        });
      } else {
        await MSG(context, 'Aviso', 'Operador não encontrado.', 1);
        setState(() {
          _os_opeController.clear();
          _ope_nomeController.clear();
          _os_opeFocus.requestFocus();
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
  // CARREGAR
  // ============================================================
  Future<void> _carregarCados() async {
    final codigo = int.tryParse(_os_trController.text) ?? 0;
    if (codigo <= 0) {
      setState(() {
        _inclusao = true;
        _habilitado = false;
        _situ_blq = false;
        _limparCampos();
        _os_dataController.text = Campo.dataFromPg(
          DateTime.now().toIso8601String().split('T')[0],
        );
        _os_horaController.text = DateTime.now()
            .toIso8601String()
            .split('T')[1]
            .substring(0, 5);
        _os_situController.text = "Aberto";
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _os_situFocus.requestFocus();
      });
      return;
    }
    _iniciarCarregamento();
    try {
      final cados = await _osServices.getById(codigo);
      if (!mounted) return;
      if (cados != null) {
        setState(() {
          _inclusao = false;
          _habilitado = false;

          _os_situController.text = cados.os_situ;
          if (_os_situController.text != "Aberto") {
            _situ_blq = true;
          }
          _os_dataController.text = Campo.dataFromPg(
            cados.os_data.toIso8601String().split('T')[0],
          );
          _os_horaController.text = cados.os_hora;
          _os_hisController.text = cados.os_his.toString();
          _his_descController.text = cados.his_desc;
          _os_cidController.text = cados.os_cid.toString();
          _cid_nomeController.text = cados.cid_nome;
          _os_titController.text = cados.os_tit.toString();
          _tit_nomeController.text = cados.tit_nome;
          _os_eqpController.text = cados.os_eqp.toString();
          _eqp_descController.text = cados.eqp_desc;
          _os_opeController.text = cados.os_ope.toString();
          _ope_nomeController.text = cados.ope_nome;
          _os_obsController.text = cados.os_obs;
          _os_htkmiController.text = Campo.doubleText(
            cados.os_htkmi,
            '999.999,9',
          );
          _os_htkmfController.text = Campo.doubleText(
            cados.os_htkmf,
            '999.999,9',
          );
          _os_qtdController.text = Campo.doubleText(cados.os_qtd, '999.999,9');
          _os_vlunitController.text = Campo.doubleText(
            cados.os_vlunit,
            '999.999,99',
          );
          _os_vldescController.text = Campo.doubleText(
            cados.os_vldesc,
            '999.999,99',
          );
          _os_vltotsController.text = Campo.doubleText(
            cados.os_vltots,
            '999.999,99',
          );
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _os_situFocus.requestFocus();
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

  // ============================================================
  // GRAVAR
  // ============================================================
  Future<void> _gravar() async {
    if (!await _valid_os_data()) return;
    if (!await _valid_os_hora()) return;
    if (!await _valid_os_htkmi()) return;
    if (!await _valid_os_htkmf()) return;
    if (!await _valid_os_vlunit()) return;
    if (!await _valid_os_vldesc()) return;

    //--------[ Se PASSOU nas Validações, CONTINUA ]------------
    final codigo = int.tryParse(_os_trController.text) ?? 0;
    final cados = Cados(
      os_tr: codigo,
      os_situ: _os_situController.text,
      os_data: DateTime.parse(Campo.dataToPg(_os_dataController.text)),
      //os_data: Campo.dataToPg(_os_dataController.text),
      os_hora: _os_horaController.text,
      os_his: int.parse(_os_hisController.text),
      his_desc: _his_descController.text,
      os_cid: int.parse(_os_cidController.text),
      cid_nome: _cid_nomeController.text,
      os_tit: int.parse(_os_titController.text),
      tit_nome: _tit_nomeController.text,
      os_eqp: int.parse(_os_eqpController.text),
      eqp_desc: _eqp_descController.text,
      os_ope: int.parse(_os_opeController.text),
      ope_nome: _ope_nomeController.text,
      os_obs: _os_obsController.text,
      os_htkmi: Campo.textDouble(_os_htkmiController.text),
      os_htkmf: Campo.textDouble(_os_htkmfController.text),
      os_qtd: Campo.textDouble(_os_qtdController.text),
      os_vlunit: Campo.textDouble(_os_vlunitController.text),
      os_vldesc: Campo.textDouble(_os_vldescController.text),
      os_vltots: Campo.textDouble(_os_vltotsController.text),
    );
    _iniciarCarregamento();
    try {
      if (codigo == 0) {
        await _osServices.add(cados);
      } else {
        await _osServices.update(cados);
      }
      if (!mounted) return;
      await MSG(context, 'Aviso', 'Registro gravado com sucesso.', 1);
      _cancelar();
    } catch (e) {
      if (!mounted) return;
      await MSG(context, 'Erro', 'Registro NÃO gravado: $e', 1);
    } finally {
      _finalizarCarregamento();
    }
  }

  // ============================================================
  // EXCLUIR
  // ============================================================

  Future<void> _excluir() async {
    final codigo = int.tryParse(_os_trController.text) ?? 0;
    if (codigo <= 0) return;
    _iniciarCarregamento();
    try {
      await _osServices.delete(codigo);
      if (!mounted) return;
      await MSG(context, 'Aviso', 'Registro excluído com sucesso.', 1);
      _cancelar();
    } catch (e) {
      if (!mounted) return;
      await MSG(context, 'Erro', 'Erro ao excluir: $e', 1);
    } finally {
      _finalizarCarregamento();
    }
  }

  // ============================================================
  // CONSULTA
  // ============================================================
  Future<void> _abrirConsulta() async {
    FocusScope.of(context).unfocus();
    final int? idSelecionado = await ConsultaCados.abrir(context);
    if (idSelecionado != null) {
      _os_trController.text = idSelecionado.toString();
      await _carregarCados();
    }
  }

  // ============================================================
  // CONSULTA  CADHIS
  // ============================================================
  Future<void> _abrirConsultaCadhis() async {
    FocusScope.of(context).unfocus();
    final int? idSelecionado = await ConsultaCadhis.abrir(context);
    if (idSelecionado != null) {
      _os_hisController.text = idSelecionado.toString();
      await _carregarCadhis();
    }
  }

  // ============================================================
  // CONSULTA  CADCID
  // ============================================================
  Future<void> _abrirConsultaCadcid() async {
    FocusScope.of(context).unfocus();
    final int? idSelecionado = await ConsultaCadcid.abrir(context);
    if (idSelecionado != null) {
      _os_cidController.text = idSelecionado.toString();
      await _carregarCadcid();
    }
  }

  // ============================================================
  // CONSULTA  CADTIT
  // ============================================================
  Future<void> _abrirConsultaCadtit() async {
    FocusScope.of(context).unfocus();
    final int? idSelecionado = await ConsultaCadtit.abrir(context);
    if (idSelecionado != null) {
      _os_titController.text = idSelecionado.toString();
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
      _os_eqpController.text = idSelecionado.toString();
      await _carregarCadeqp();
    }
  }

  // ============================================================
  // CONSULTA  CADOPE
  // ============================================================
  Future<void> _abrirConsultaCadope() async {
    FocusScope.of(context).unfocus();
    final int? idSelecionado = await ConsultaCadope.abrir(context);
    if (idSelecionado != null) {
      _os_opeController.text = idSelecionado.toString();
      await _carregarCadope();
    }
  }

  //========================[ _valid_os_data ]===========
  Future<bool> _valid_os_data() async {
    if (!Campo.validaData(_os_dataController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data inválida.'),
          duration: Duration(seconds: 2),
        ),
      );
      _os_dataFocus.requestFocus(); // volta foco no campo
      return false;
    }
    return true;
  }

  //========================[ _valid_os_hora ]===========
  Future<bool> _valid_os_hora() async {
    if (!Campo.validaHora(_os_horaController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hora inválida.'),
          duration: Duration(seconds: 2),
        ),
      );
      _os_horaFocus.requestFocus(); // volta foco no campo
      return false;
    }
    return true;
  }

  //========================[ _valid_os_HTKMI ]===========
  Future<bool> _valid_os_htkmi() async {
    final valor = Campo.textDouble(_os_htkmiController.text);
    if (valor <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('O campo HT/KMi deve ser informado.'),
          duration: Duration(seconds: 2),
        ),
      );
      _os_htkmiFocus.requestFocus(); // volta foco no campo
      return false;
    }
    return true;
  }

  //========================[ _valid_os_HTKMF ]===========
  Future<bool> _valid_os_htkmf() async {
    final htkmi = Campo.textDouble(_os_htkmiController.text);
    final htkmf = Campo.textDouble(_os_htkmfController.text);
    if (htkmf <= htkmi) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('O campo HT/KMf deve ser > que HT/KMi.'),
          duration: Duration(seconds: 2),
        ),
      );
      _os_htkmfFocus.requestFocus(); // volta foco no campo
      return false;
    }
    final qtd = htkmf - htkmi;
    _os_qtdController.text = Campo.doubleText(qtd, '999.999,9');
    return true;
  }

  //========================[ _valid_os_vlunit ]===========
  Future<bool> _valid_os_vlunit() async {
    final vlunit = Campo.textDouble(_os_vlunitController.text);
    final qtd = Campo.textDouble(_os_qtdController.text);
    if (vlunit <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('O campo Vl.Unit. deve ser informado.'),
          duration: Duration(seconds: 2),
        ),
      );
      _os_vlunitFocus.requestFocus(); // volta foco no campo
      return false;
    }
    final tots = qtd * vlunit;
    _os_vltotsController.text = Campo.doubleText(tots, '999.999,99');
    return true;
  }

  //========================[ _valid_os_vldesc ]===========
  Future<bool> _valid_os_vldesc() async {
    final vldesc = Campo.textDouble(_os_vldescController.text);
    final vlunit = Campo.textDouble(_os_vlunitController.text);
    final qtd = Campo.textDouble(_os_qtdController.text);
    if (vldesc < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('O campo Vl.Desc. não pode ser negativo.'),
          duration: Duration(seconds: 2),
        ),
      );
      _os_vldescFocus.requestFocus(); // volta foco no campo
      return false;
    }
    final tots = ((qtd * vlunit) - vldesc);
    _os_vltotsController.text = Campo.doubleText(tots, '999.999,99');
    return true;
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget buildBody(BuildContext context) {
    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          // F2
          if (event.logicalKey == LogicalKeyboardKey.f2) {
            if (_habilitado && _os_trFocus.hasFocus) {
              _abrirConsulta();
              return KeyEventResult.handled;
            }
            if (!_habilitado && _os_hisFocus.hasFocus) {
              _abrirConsultaCadhis();
              return KeyEventResult.handled;
            }
            if (!_habilitado && _os_cidFocus.hasFocus) {
              _abrirConsultaCadcid();
              return KeyEventResult.handled;
            }
            if (!_habilitado && _os_titFocus.hasFocus) {
              _abrirConsultaCadtit();
              return KeyEventResult.handled;
            }
            if (!_habilitado && _os_eqpFocus.hasFocus) {
              _abrirConsultaCadeqp();
              return KeyEventResult.handled;
            }
            if (!_habilitado && _os_opeFocus.hasFocus) {
              _abrirConsultaCadope();
              return KeyEventResult.handled;
            }
          }
          // ESC (mantém comportamento original)
          if (event.logicalKey == LogicalKeyboardKey.escape) {
            onEscapePressed();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: Stack(
        //---------------------------------------
        children: [
          FocusTraversalGroup(
            policy: OrderedTraversalPolicy(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Campo(
                      tipo: TipoCampo.inteiro,
                      titulo: 'TR [2c/F2]',
                      controller: _os_trController,
                      focusNode: _os_trFocus,
                      nextFocus: _os_situFocus,
                      tamanho: 6,
                      enabled: _habilitado,
                      onDoubleTap: () {
                        _abrirConsulta();
                      },
                      onSubmitted: () async {
                        await _carregarCados();
                        return true;
                      },
                    ),
                    const Spacer(),
                    Campo(
                      tipo: TipoCampo.lista,
                      titulo: 'Situação',
                      controller: _os_situController,
                      lista: 'Aberto,Fechado,Quitado',
                      focusNode: _os_situFocus,
                      nextFocus: _os_dataFocus,
                      enabled: !_habilitado,
                    ),
                  ],
                ),

                const SizedBox(height: 10),
                Row(
                  children: [
                    Campo(
                      tipo: TipoCampo.data,
                      titulo: 'Data',
                      controller: _os_dataController,
                      focusNode: _os_dataFocus,
                      nextFocus: _os_horaFocus,
                      enabled: !_habilitado && !_situ_blq,
                      onSubmitted: _valid_os_data,
                    ),
                    const Spacer(),
                    Campo(
                      tipo: TipoCampo.mascara,
                      titulo: 'Hora',
                      controller: _os_horaController,
                      focusNode: _os_horaFocus,
                      nextFocus: _os_hisFocus,
                      mascara: '99:99',
                      enabled: !_habilitado && !_situ_blq,
                      onSubmitted: _valid_os_hora,
                    ),
                  ],
                ),

                const SizedBox(height: 10),
                Row(
                  children: [
                    Campo(
                      tipo: TipoCampo.inteiro,
                      titulo: 'Histórico',
                      controller: _os_hisController,
                      focusNode: _os_hisFocus,
                      nextFocus: _os_cidFocus,
                      tamanho: 5,
                      enabled: !_habilitado && !_situ_blq,
                      onDoubleTap: () {
                        _abrirConsultaCadhis();
                      },
                      onSubmitted: _carregarCadhis,
                    ),
                    SizedBox(width: 5),
                    Expanded(
                      child: Campo(
                        tipo: TipoCampo.texto,
                        titulo: '',
                        controller: _his_descController,
                        focusNode: _his_descFocus,
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
                      titulo: 'Cidade',
                      controller: _os_cidController,
                      focusNode: _os_cidFocus,
                      nextFocus: _os_titFocus,
                      tamanho: 5,
                      enabled: !_habilitado && !_situ_blq,
                      onDoubleTap: () {
                        _abrirConsultaCadcid();
                      },
                      onSubmitted: _carregarCadcid,
                    ),
                    SizedBox(width: 5),
                    Expanded(
                      child: Campo(
                        tipo: TipoCampo.texto,
                        titulo: '',
                        controller: _cid_nomeController,
                        focusNode: _cid_nomeFocus,
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
                      titulo: 'Titular',
                      controller: _os_titController,
                      focusNode: _os_titFocus,
                      nextFocus: _os_eqpFocus,
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
                      controller: _os_eqpController,
                      focusNode: _os_eqpFocus,
                      nextFocus: _os_opeFocus,
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
                      tipo: TipoCampo.inteiro,
                      titulo: 'Operador',
                      controller: _os_opeController,
                      focusNode: _os_opeFocus,
                      nextFocus: _os_obsFocus,
                      tamanho: 5,
                      enabled: !_habilitado && !_situ_blq,
                      onDoubleTap: () {
                        _abrirConsultaCadope();
                      },
                      onSubmitted: _carregarCadope,
                    ),
                    SizedBox(width: 5),
                    Expanded(
                      child: Campo(
                        tipo: TipoCampo.texto,
                        titulo: '',
                        controller: _ope_nomeController,
                        focusNode: _ope_nomeFocus,
                        tamanho: 50,
                        enabled: false,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),
                Campo(
                  tipo: TipoCampo.texto,
                  titulo: 'Observação',
                  controller: _os_obsController,
                  focusNode: _os_obsFocus,
                  nextFocus: _os_htkmiFocus,
                  tamanho: 50,
                  enabled: !_habilitado && !_situ_blq,
                ),

                const SizedBox(height: 10),
                Row(
                  children: [
                    Campo(
                      tipo: TipoCampo.double,
                      titulo: 'HT/KM i',
                      controller: _os_htkmiController,
                      focusNode: _os_htkmiFocus,
                      mascara: '999.999,9',
                      onSubmitted: _valid_os_htkmi,
                      nextFocus: _os_htkmfFocus,
                      enabled: !_habilitado && !_situ_blq,
                    ),
                    const Spacer(),
                    Campo(
                      tipo: TipoCampo.double,
                      titulo: 'HT/KM f',
                      controller: _os_htkmfController,
                      focusNode: _os_htkmfFocus,
                      mascara: '999.999,9',
                      onSubmitted: _valid_os_htkmf,
                      nextFocus: _os_vlunitFocus,
                      enabled: !_habilitado && !_situ_blq,
                    ),
                  ],
                ),

                const SizedBox(height: 10),
                Row(
                  children: [
                    Campo(
                      tipo: TipoCampo.double,
                      titulo: 'Quantidade',
                      controller: _os_qtdController,
                      focusNode: _os_qtdFocus,
                      enabled: false,
                    ),
                    const Spacer(),
                    Campo(
                      tipo: TipoCampo.double,
                      titulo: 'Vl. Unit.',
                      controller: _os_vlunitController,
                      focusNode: _os_vlunitFocus,
                      mascara: '999.999,99',
                      onSubmitted: _valid_os_vlunit,
                      nextFocus: _os_vldescFocus,
                      enabled: !_habilitado && !_situ_blq,
                    ),
                  ],
                ),

                const SizedBox(height: 10),
                Row(
                  children: [
                    Campo(
                      tipo: TipoCampo.double,
                      titulo: 'Vl. Desconto',
                      controller: _os_vldescController,
                      focusNode: _os_vldescFocus,
                      mascara: '999.999,99',
                      onSubmitted: _valid_os_vldesc,
                      nextFocus: _gravarFocus,
                      enabled: !_habilitado && !_situ_blq,
                    ),
                    const Spacer(),
                    Campo(
                      tipo: TipoCampo.double,
                      titulo: 'VL. Total',
                      controller: _os_vltotsController,
                      focusNode: _os_vltotsFocus,
                      mascara: '999.999,99',
                      enabled: false,
                    ),
                  ],
                ),

                const SizedBox(height: 10),
                BotoesFormulario(
                  habilitado: _habilitado,
                  inclusao: _inclusao,
                  bloqueado: _situ_blq,
                  onGravar: _gravar,
                  onExcluir: _excluir,
                  onCancelar: _cancelar,
                  focusGravar: _gravarFocus,
                ),
              ],
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
      ),
    );
  }

  @override
  void dispose() {
    _os_trController.dispose();
    _os_situController.dispose();
    _os_dataController.dispose();
    _os_horaController.dispose();
    _os_hisController.dispose();
    _his_descController.dispose();
    _os_cidController.dispose();
    _cid_nomeController.dispose();
    _os_titController.dispose();
    _tit_nomeController.dispose();
    _os_eqpController.dispose();
    _eqp_descController.dispose();
    _os_opeController.dispose();
    _ope_nomeController.dispose();
    _os_obsController.dispose();
    _os_htkmiController.dispose();
    _os_htkmfController.dispose();
    _os_qtdController.dispose();
    _os_vlunitController.dispose();
    _os_vldescController.dispose();
    _os_vltotsController.dispose();

    _os_trFocus.dispose();
    _os_situFocus.dispose();
    _os_dataFocus.dispose();
    _os_horaFocus.dispose();
    _os_hisFocus.dispose();
    _his_descFocus.dispose();
    _os_cidFocus.dispose();
    _cid_nomeFocus.dispose();
    _os_titFocus.dispose();
    _tit_nomeFocus.dispose();
    _os_eqpFocus.dispose();
    _eqp_descFocus.dispose();
    _os_opeFocus.dispose();
    _ope_nomeFocus.dispose();
    _os_obsFocus.dispose();
    _os_htkmiFocus.dispose();
    _os_htkmfFocus.dispose();
    _os_qtdFocus.dispose();
    _os_vlunitFocus.dispose();
    _os_vldescFocus.dispose();
    _os_vltotsFocus.dispose();

    _gravarFocus.dispose();
    super.dispose();
  }
}
