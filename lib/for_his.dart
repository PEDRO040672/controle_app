import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'widgets/botoes.dart';
import '../widgets/campo.dart';
import '../widgets/msg.dart';
import '../models/cadhis_models.dart';
import 'services/cadhis_services.dart';
import 'base_form.dart';
import 'con_his.dart';

class ForHisPage extends BaseFormPage {
  const ForHisPage({super.key, required super.onClose})
    : super(titulo: 'Históricos');

  @override
  State<ForHisPage> createState() => _ForHisState();
}

class _ForHisState extends BaseFormState<ForHisPage> {
  final CadhisServices _hisServices = CadhisServices();

  final _his_idController = TextEditingController();
  final _his_descController = TextEditingController();
  final _his_ccController = TextEditingController();
  final _his_intervaloController = TextEditingController();

  final _his_idFocus = FocusNode();
  final _his_descFocus = FocusNode();
  final _his_ccFocus = FocusNode();
  final _his_intervaloFocus = FocusNode();
  final _gravarFocus = FocusNode();

  bool _inclusao = true;
  bool _habilitado = true;
  bool _carregando = false;

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
  // INIT
  // ============================================================
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _his_idFocus.requestFocus();
      }
    });
  }

  // ============================================================
  // LIMPAR
  // ============================================================
  void _limparCampos() {
    _his_idController.clear();
    _his_descController.clear();
    _his_ccController.clear();
    _his_intervaloController.clear();
  }

  // ============================================================
  // CANCELAR
  // ============================================================
  void _cancelar() {
    FocusScope.of(context).unfocus();
    setState(() {
      _inclusao = true;
      _habilitado = true;
      _limparCampos();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _his_idFocus.requestFocus();
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
  // CARREGAR
  // ============================================================
  Future<void> _carregarCadhis() async {
    final codigo = int.tryParse(_his_idController.text) ?? 0;
    if (codigo <= 0) {
      setState(() {
        _inclusao = true;
        _habilitado = false;
        _limparCampos();
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _his_descFocus.requestFocus();
      });
      return;
    }
    _iniciarCarregamento();
    try {
      final cadhis = await _hisServices.getById(codigo);
      if (!mounted) return;
      if (cadhis != null) {
        setState(() {
          _inclusao = false;
          _habilitado = false;
          _his_descController.text = cadhis.his_desc;
          _his_ccController.text = cadhis.his_cc;
          _his_intervaloController.text = Campo.doubleText(
            cadhis.his_intervalo,
            '999.999,9',
          );
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _his_descFocus.requestFocus();
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
    if (!await _valid_his_desc()) return;
    if (!await _valid_his_intervalo()) return;

    //--------[ Se PASSOU nas Validações, CONTINUA ]------------
    final codigo = int.tryParse(_his_idController.text) ?? 0;
    final cadhis = Cadhis(
      his_id: codigo,
      his_desc: _his_descController.text,
      his_cc: _his_ccController.text,
      his_intervalo: Campo.textDouble(_his_intervaloController.text),
    );
    _iniciarCarregamento();
    try {
      if (codigo == 0) {
        await _hisServices.add(cadhis);
      } else {
        await _hisServices.update(cadhis);
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
    final codigo = int.tryParse(_his_idController.text) ?? 0;
    if (codigo <= 0) return;
    _iniciarCarregamento();
    try {
      await _hisServices.delete(codigo);
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

    final int? idSelecionado = await ConsultaCadhis.abrir(context);

    if (idSelecionado != null) {
      _his_idController.text = idSelecionado.toString();
      await _carregarCadhis();
    }
  }

  //========================[ _valid_his_desc ]===========
  Future<bool> _valid_his_desc() async {
    _his_descController.text = _his_descController.text.trim();
    if (_his_descController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('O campo DESCRIÇÃO está vazio.'),
          duration: Duration(seconds: 2),
        ),
      );
      _his_descFocus.requestFocus(); // volta foco no campo
      return false;
    }
    return true;
  }

  //========================[ _valid_his_intervalo ]===========
  Future<bool> _valid_his_intervalo() async {
    if (_his_ccController.text != "Manutenção") {
      _his_intervaloController.clear();
    }
    final valor = Campo.textDouble(_his_intervaloController.text);
    if (valor < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('O campo INTERVALO não pode ser negativo.'),
          duration: Duration(seconds: 2),
        ),
      );
      _his_intervaloFocus.requestFocus(); // volta foco no campo
      return false;
    }
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
            if (_habilitado && _his_idFocus.hasFocus) {
              _abrirConsulta();
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
                Campo(
                  tipo: TipoCampo.inteiro,
                  titulo: 'ID [2c/F2]',
                  controller: _his_idController,
                  focusNode: _his_idFocus,
                  nextFocus: _his_descFocus,
                  tamanho: 5,
                  //zeroEsquerda: true,
                  enabled: _habilitado,
                  onDoubleTap: () {
                    _abrirConsulta();
                  },
                  onSubmitted: () async {
                    await _carregarCadhis();
                    return true;
                  },
                ),
                const SizedBox(height: 10),
                Campo(
                  tipo: TipoCampo.texto,
                  titulo: 'Descrição',
                  controller: _his_descController,
                  focusNode: _his_descFocus,
                  onSubmitted: _valid_his_desc,
                  nextFocus: _his_ccFocus,
                  tamanho: 50,
                  enabled: !_habilitado,
                ),
                const SizedBox(height: 10),
                Campo(
                  tipo: TipoCampo.lista,
                  titulo: 'C. Custo',
                  controller: _his_ccController,
                  lista: 'Receita,Manutenção,Combustível,Diversos,Salário',
                  focusNode: _his_ccFocus,
                  nextFocus: _his_intervaloFocus,
                  enabled: !_habilitado,
                ),
                const SizedBox(height: 10),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _his_ccController,
                  builder: (context, value, _) {
                    return Campo(
                      tipo: TipoCampo.double,
                      titulo: 'Intervalo',
                      controller: _his_intervaloController,
                      focusNode: _his_intervaloFocus,
                      mascara: '999.999,9',
                      onSubmitted: _valid_his_intervalo,
                      nextFocus: _gravarFocus,
                      enabled: !_habilitado && value.text == "Manutenção",
                    );
                  },
                ),
                const SizedBox(height: 10),
                BotoesFormulario(
                  habilitado: _habilitado,
                  inclusao: _inclusao,
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
    _his_idController.dispose();
    _his_descController.dispose();
    _his_ccController.dispose();
    _his_intervaloController.dispose();
    _his_idFocus.dispose();
    _his_descFocus.dispose();
    _his_ccFocus.dispose();
    _his_intervaloFocus.dispose();
    _gravarFocus.dispose();
    super.dispose();
  }
}
