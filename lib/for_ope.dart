import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'widgets/botoes.dart';
import '../widgets/campo.dart';
import '../widgets/msg.dart';
import '../models/cadope_models.dart';
import 'services/cadope_services.dart';
import 'base_form.dart';
import 'con_ope.dart';

class ForOpePage extends BaseFormPage {
  const ForOpePage({super.key, required super.onClose})
    : super(titulo: 'Operadores');

  @override
  State<ForOpePage> createState() => _ForOpeState();
}

class _ForOpeState extends BaseFormState<ForOpePage> {
  final CadopeServices _opeServices = CadopeServices();

  final _ope_idController = TextEditingController();
  final _ope_nomeController = TextEditingController();
  final _ope_fixoController = TextEditingController();
  final _ope_percController = TextEditingController();

  final _ope_idFocus = FocusNode();
  final _ope_nomeFocus = FocusNode();
  final _ope_fixoFocus = FocusNode();
  final _ope_percFocus = FocusNode();
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
        _ope_idFocus.requestFocus();
      }
    });
  }

  // ============================================================
  // LIMPAR
  // ============================================================
  void _limparCampos() {
    _ope_idController.clear();
    _ope_nomeController.clear();
    _ope_fixoController.clear();
    _ope_percController.clear();
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
      if (mounted) _ope_idFocus.requestFocus();
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
  Future<void> _carregarCadope() async {
    final codigo = int.tryParse(_ope_idController.text) ?? 0;
    if (codigo <= 0) {
      setState(() {
        _inclusao = true;
        _habilitado = false;
        _limparCampos();
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _ope_nomeFocus.requestFocus();
      });
      return;
    }
    _iniciarCarregamento();
    try {
      final cadope = await _opeServices.getById(codigo);
      if (!mounted) return;
      if (cadope != null) {
        setState(() {
          _inclusao = false;
          _habilitado = false;
          _ope_nomeController.text = cadope.ope_nome;
          _ope_fixoController.text = Campo.doubleText(
            cadope.ope_fixo,
            '99.999,99',
          );
          _ope_percController.text = Campo.doubleText(
            cadope.ope_perc,
            '999,99',
          );
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _ope_nomeFocus.requestFocus();
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
    if (!await _valid_ope_nome()) return;
    if (!await _valid_ope_fixo()) return;
    if (!await _valid_ope_perc()) return;

    //--------[ Se PASSOU nas Validações, CONTINUA ]------------
    final codigo = int.tryParse(_ope_idController.text) ?? 0;
    final cadope = Cadope(
      ope_id: codigo,
      ope_nome: _ope_nomeController.text,
      ope_fixo: Campo.textDouble(_ope_fixoController.text),
      ope_perc: Campo.textDouble(_ope_percController.text),
    );
    _iniciarCarregamento();
    try {
      if (codigo == 0) {
        await _opeServices.add(cadope);
      } else {
        await _opeServices.update(cadope);
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
    final codigo = int.tryParse(_ope_idController.text) ?? 0;
    if (codigo <= 0) return;
    _iniciarCarregamento();
    try {
      await _opeServices.delete(codigo);
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

    final int? idSelecionado = await ConsultaCadope.abrir(context);

    if (idSelecionado != null) {
      _ope_idController.text = idSelecionado.toString();
      await _carregarCadope();
    }
  }

  //========================[ _valid_ope_nome ]===========
  Future<bool> _valid_ope_nome() async {
    _ope_nomeController.text = _ope_nomeController.text.trim();
    if (_ope_nomeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('O campo NOME está vazio.'),
          duration: Duration(seconds: 2),
        ),
      );
      _ope_nomeFocus.requestFocus(); // volta foco no campo
      return false;
    }
    return true;
  }

  //========================[ _valid_ope_fixo ]===========
  Future<bool> _valid_ope_fixo() async {
    final valor = Campo.textDouble(_ope_fixoController.text);
    if (valor < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('O campo FIXO não pode ser negativo.'),
          duration: Duration(seconds: 2),
        ),
      );
      _ope_fixoFocus.requestFocus(); // volta foco no campo
      return false;
    }
    return true;
  }

  //========================[ _valid_ope_fixo ]===========
  Future<bool> _valid_ope_perc() async {
    final valor = Campo.textDouble(_ope_percController.text);
    if (valor < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('O campo PERC. não pode ser negativo.'),
          duration: Duration(seconds: 2),
        ),
      );
      _ope_percFocus.requestFocus(); // volta foco no campo
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
            if (_habilitado && _ope_idFocus.hasFocus) {
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
                  controller: _ope_idController,
                  focusNode: _ope_idFocus,
                  nextFocus: _ope_nomeFocus,
                  tamanho: 5,
                  //zeroEsquerda: true,
                  enabled: _habilitado,
                  onDoubleTap: () {
                    _abrirConsulta();
                  },
                  onSubmitted: () async {
                    await _carregarCadope();
                    return true;
                  },
                ),
                const SizedBox(height: 10),
                Campo(
                  tipo: TipoCampo.texto,
                  titulo: 'Nome',
                  controller: _ope_nomeController,
                  focusNode: _ope_nomeFocus,
                  onSubmitted: _valid_ope_nome,
                  nextFocus: _ope_fixoFocus,
                  tamanho: 50,
                  enabled: !_habilitado,
                ),
                const SizedBox(height: 10),
                Campo(
                  tipo: TipoCampo.double,
                  titulo: 'Vl.Fixo',
                  controller: _ope_fixoController,
                  focusNode: _ope_fixoFocus,
                  mascara: '99.999,99',
                  onSubmitted: _valid_ope_fixo,
                  nextFocus: _ope_percFocus,
                  enabled: !_habilitado,
                ),
                const SizedBox(height: 10),
                Campo(
                  tipo: TipoCampo.double,
                  titulo: 'Perc.%',
                  controller: _ope_percController,
                  focusNode: _ope_percFocus,
                  mascara: '999,99',
                  onSubmitted: _valid_ope_perc,
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
    _ope_idController.dispose();
    _ope_nomeController.dispose();
    _ope_fixoController.dispose();
    _ope_percController.dispose();
    _ope_idFocus.dispose();
    _ope_nomeFocus.dispose();
    _ope_fixoFocus.dispose();
    _ope_percFocus.dispose();
    _gravarFocus.dispose();
    super.dispose();
  }
}
