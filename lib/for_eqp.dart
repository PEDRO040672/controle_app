import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'widgets/botoes.dart';
import '../widgets/campo.dart';
import '../widgets/msg.dart';
import '../models/cadeqp_models.dart';
import 'services/cadeqp_services.dart';
import 'base_form.dart';
import 'con_eqp.dart';

class ForEqpPage extends BaseFormPage {
  const ForEqpPage({super.key, required super.onClose})
    : super(titulo: 'Equipamentos');

  @override
  State<ForEqpPage> createState() => _ForEqpState();
}

class _ForEqpState extends BaseFormState<ForEqpPage> {
  final CadeqpServices _eqpServices = CadeqpServices();

  final _eqp_idController = TextEditingController();
  final _eqp_descController = TextEditingController();
  final _eqp_htkmController = TextEditingController();

  final _eqp_idFocus = FocusNode();
  final _eqp_descFocus = FocusNode();
  final _eqp_htkmFocus = FocusNode();
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
        _eqp_idFocus.requestFocus();
      }
    });
  }

  // ============================================================
  // LIMPAR
  // ============================================================
  void _limparCampos() {
    _eqp_idController.clear();
    _eqp_descController.clear();
    _eqp_htkmController.clear();
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
      if (mounted) _eqp_idFocus.requestFocus();
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
  Future<void> _carregarCadeqp() async {
    final codigo = int.tryParse(_eqp_idController.text) ?? 0;
    if (codigo <= 0) {
      setState(() {
        _inclusao = true;
        _habilitado = false;
        _limparCampos();
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _eqp_descFocus.requestFocus();
      });
      return;
    }
    _iniciarCarregamento();
    try {
      final cadeqp = await _eqpServices.getById(codigo);
      if (!mounted) return;
      if (cadeqp != null) {
        setState(() {
          _inclusao = false;
          _habilitado = false;
          _eqp_descController.text = cadeqp.eqp_desc;
          //_eqp_htkmController.text = cadeqp.eqp_htkm;
          _eqp_htkmController.text = Campo.doubleText(
            cadeqp.eqp_htkm,
            '999.999,9',
          );
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _eqp_descFocus.requestFocus();
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
    if (!await _valid_eqp_desc()) return;
    //if (!await _valid_eqp_htkm()) return;

    //--------[ Se PASSOU nas Validações, CONTINUA ]------------
    final codigo = int.tryParse(_eqp_idController.text) ?? 0;
    final cadeqp = Cadeqp(
      eqp_id: codigo,
      eqp_desc: _eqp_descController.text,
      eqp_htkm: Campo.textDouble(_eqp_htkmController.text),
    );
    _iniciarCarregamento();
    try {
      if (codigo == 0) {
        await _eqpServices.add(cadeqp);
      } else {
        await _eqpServices.update(cadeqp);
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
    final codigo = int.tryParse(_eqp_idController.text) ?? 0;
    if (codigo <= 0) return;
    _iniciarCarregamento();
    try {
      await _eqpServices.delete(codigo);
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

    final int? idSelecionado = await ConsultaCadeqp.abrir(context);

    if (idSelecionado != null) {
      _eqp_idController.text = idSelecionado.toString();
      await _carregarCadeqp();
    }
  }

  //========================[ _valid_eqp_desc ]===========
  Future<bool> _valid_eqp_desc() async {
    _eqp_descController.text = _eqp_descController.text.trim();
    if (_eqp_descController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('O campo DESCRIÇÃO está vazio.'),
          duration: Duration(seconds: 2),
        ),
      );
      _eqp_descFocus.requestFocus(); // volta foco no campo
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
            if (_habilitado && _eqp_idFocus.hasFocus) {
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
                  controller: _eqp_idController,
                  focusNode: _eqp_idFocus,
                  nextFocus: _eqp_descFocus,
                  tamanho: 5,
                  //zeroEsquerda: true,
                  enabled: _habilitado,
                  onDoubleTap: () {
                    _abrirConsulta();
                  },
                  onSubmitted: () async {
                    await _carregarCadeqp();
                    return true;
                  },
                ),
                const SizedBox(height: 10),
                Campo(
                  tipo: TipoCampo.texto,
                  titulo: 'Descrição',
                  controller: _eqp_descController,
                  focusNode: _eqp_descFocus,
                  onSubmitted: _valid_eqp_desc,
                  nextFocus: _eqp_htkmFocus,
                  tamanho: 50,
                  enabled: !_habilitado,
                ),
                const SizedBox(height: 10),
                Campo(
                  tipo: TipoCampo.double,
                  titulo: 'HT/KM',
                  controller: _eqp_htkmController,
                  focusNode: _eqp_htkmFocus,
                  mascara: '999.999,9',
                  nextFocus: _gravarFocus,
                  enabled: !_habilitado,
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
    _eqp_idController.dispose();
    _eqp_descController.dispose();
    _eqp_htkmController.dispose();
    _eqp_idFocus.dispose();
    _eqp_descFocus.dispose();
    _eqp_htkmFocus.dispose();
    _gravarFocus.dispose();
    super.dispose();
  }
}
