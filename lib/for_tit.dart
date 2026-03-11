import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../models/cadtit_models.dart';
import 'services/cadtit_services.dart';
import '../widgets/campo.dart';
import '../widgets/msg.dart';
import 'widgets/botoes.dart';
import 'base_form.dart';
import 'con_tit.dart';

class ForTitPage extends BaseFormPage {
  const ForTitPage({super.key, required super.onClose})
    : super(titulo: 'Titulares');

  @override
  State<ForTitPage> createState() => _ForTitState();
}

class _ForTitState extends BaseFormState<ForTitPage> {
  final CadtitServices _services = CadtitServices();

  final _tit_idController = TextEditingController();
  final _tit_nomeController = TextEditingController();
  final _tit_docController = TextEditingController();
  final _tit_foneController = TextEditingController();
  final _tit_endController = TextEditingController();
  final _tit_baiController = TextEditingController();
  final _tit_cepController = TextEditingController();
  final _tit_cidController = TextEditingController();
  final _cid_nomeController = TextEditingController();
  final _tit_obsController = TextEditingController();

  final _tit_idFocus = FocusNode();
  final _tit_nomeFocus = FocusNode();
  final _tit_docFocus = FocusNode();
  final _tit_foneFocus = FocusNode();
  final _tit_endFocus = FocusNode();
  final _tit_baiFocus = FocusNode();
  final _tit_cepFocus = FocusNode();
  final _tit_cidFocus = FocusNode();
  final _tit_obsFocus = FocusNode();
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
        _tit_idFocus.requestFocus();
      }
    });
  }

  // ============================================================
  // LIMPAR
  // ============================================================
  void _limparCampos() {
    _tit_idController.clear();
    _tit_nomeController.clear();
    _tit_docController.clear();
    _tit_foneController.clear();
    _tit_endController.clear();
    _tit_baiController.clear();
    _tit_cepController.clear();
    _tit_cidController.clear();
    _cid_nomeController.clear();
    _tit_obsController.clear();
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
      if (mounted) _tit_idFocus.requestFocus();
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
  Future<void> _carregarCadtit() async {
    final codigo = int.tryParse(_tit_idController.text) ?? 0;
    if (codigo <= 0) {
      setState(() {
        _inclusao = true;
        _habilitado = false;
        _limparCampos();
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _tit_nomeFocus.requestFocus();
      });
      return;
    }
    _iniciarCarregamento();
    try {
      final cadtit = await _services.getById(codigo);
      if (!mounted) return;
      if (cadtit != null) {
        setState(() {
          _inclusao = false;
          _habilitado = false;
          _tit_nomeController.text = cadtit.tit_nome;
          _tit_docController.text = cadtit.tit_doc;
          _tit_foneController.text = cadtit.tit_fone;
          _tit_endController.text = cadtit.tit_end;
          _tit_baiController.text = cadtit.tit_bai;
          _tit_cepController.text = cadtit.tit_cep;
          _tit_cidController.text = cadtit.tit_cid.toString();
          _cid_nomeController.text = cadtit.cid_nome;
          _tit_obsController.text = cadtit.tit_obs;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _tit_nomeFocus.requestFocus();
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
    if (!await _valid_tit_nome()) return;
    if (!await _valid_tit_fone()) return;

    //--------[ Se PASSOU nas Validações, CONTINUA ]------------
    final codigo = int.tryParse(_tit_idController.text) ?? 0;
    final cadtit = Cadtit(
      tit_id: codigo,
      tit_nome: _tit_nomeController.text,
      tit_doc: _tit_docController.text,
      tit_fone: _tit_foneController.text,
      tit_end: _tit_endController.text,
      tit_bai: _tit_baiController.text,
      tit_cep: _tit_cepController.text,
      tit_cid: int.parse(_tit_cidController.text),
      cid_nome: _cid_nomeController.text,
      tit_obs: _tit_obsController.text,
    );
    _iniciarCarregamento();
    try {
      if (codigo == 0) {
        await _services.add(cadtit);
      } else {
        await _services.update(cadtit);
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
    final codigo = int.tryParse(_tit_idController.text) ?? 0;
    if (codigo <= 0) return;
    _iniciarCarregamento();
    try {
      await _services.delete(codigo);
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

    final int? idSelecionado = await ConsultaCadtit.abrir(context);

    if (idSelecionado != null) {
      _tit_idController.text = idSelecionado.toString();
      await _carregarCadtit();
    }
  }

  //========================[ _valid_tit_nome ]===========
  Future<bool> _valid_tit_nome() async {
    _tit_nomeController.text = _tit_nomeController.text.trim();
    if (_tit_nomeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('O campo NOME está vazio.'),
          duration: Duration(seconds: 2),
        ),
      );
      _tit_nomeFocus.requestFocus(); // volta foco no campo
      return false;
    }
    return true;
  }

  //========================[ _valid_tit_uf ]===========
  Future<bool> _valid_tit_fone() async {
    _tit_foneController.text = _tit_foneController.text.trim();
    if (_tit_foneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('O campo Fone está vazio.'),
          duration: Duration(seconds: 2),
        ),
      );
      _tit_foneFocus.requestFocus(); // volta foco no campo
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
            if (_habilitado && _tit_idFocus.hasFocus) {
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
                  controller: _tit_idController,
                  focusNode: _tit_idFocus,
                  nextFocus: _tit_nomeFocus,
                  tamanho: 5,
                  zeroEsquerda: true,
                  enabled: _habilitado,
                  onDoubleTap: () {
                    _abrirConsulta();
                  },
                  onSubmitted: () async {
                    await _carregarCadtit();
                    return true;
                  },
                ),
                const SizedBox(height: 10),
                Campo(
                  tipo: TipoCampo.texto,
                  titulo: 'Nome',
                  controller: _tit_nomeController,
                  focusNode: _tit_nomeFocus,
                  onSubmitted: _valid_tit_nome,
                  nextFocus: _tit_docFocus,
                  tamanho: 50,
                  enabled: !_habilitado,
                ),
                const SizedBox(height: 10),
                Campo(
                  tipo: TipoCampo.texto,
                  titulo: 'Documento',
                  controller: _tit_docController,
                  focusNode: _tit_docFocus,
                  nextFocus: _tit_foneFocus,
                  tamanho: 20,
                  enabled: !_habilitado,
                ),
                const SizedBox(height: 10),
                Campo(
                  tipo: TipoCampo.mascara,
                  titulo: 'Fone',
                  controller: _tit_foneController,
                  focusNode: _tit_foneFocus,
                  onSubmitted: _valid_tit_fone,
                  nextFocus: _tit_endFocus,
                  mascara: '(99) ?9999-9999',
                  enabled: !_habilitado,
                ),
                const SizedBox(height: 10),
                Campo(
                  tipo: TipoCampo.texto,
                  titulo: 'Endereço',
                  controller: _tit_endController,
                  focusNode: _tit_endFocus,
                  nextFocus: _tit_baiFocus,
                  tamanho: 50,
                  enabled: !_habilitado,
                ),
                const SizedBox(height: 10),
                Campo(
                  tipo: TipoCampo.texto,
                  titulo: 'Bairro',
                  controller: _tit_baiController,
                  focusNode: _tit_baiFocus,
                  nextFocus: _tit_cepFocus,
                  tamanho: 30,
                  enabled: !_habilitado,
                ),
                const SizedBox(height: 10),
                Campo(
                  tipo: TipoCampo.mascara,
                  titulo: 'CEP',
                  controller: _tit_cepController,
                  focusNode: _tit_cepFocus,
                  nextFocus: _tit_cidFocus,
                  mascara: '99.999-999',
                  enabled: !_habilitado,
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Campo(
                      tipo: TipoCampo.inteiro,
                      titulo: 'Cidade',
                      controller: _tit_cidController,
                      focusNode: _tit_cidFocus,
                      nextFocus: _tit_obsFocus,
                      tamanho: 5,
                      zeroEsquerda: true,
                      enabled: !_habilitado,
                      //onDoubleTap: () {
                      //  _abrirConsulta();
                      //},
                      //onSubmitted: () async {
                      //  await _carregarCadtit();
                      //  return true;
                      //},
                    ),
                    SizedBox(width: 5),
                    Campo(
                      tipo: TipoCampo.texto,
                      titulo: 'Nome da Cidade',
                      controller: _cid_nomeController,
                      focusNode: _tit_obsFocus,
                      tamanho: 50,
                      enabled: false,
                    ),
                  ],
                ),

                const SizedBox(height: 10),
                Campo(
                  tipo: TipoCampo.texto,
                  titulo: 'Observação',
                  controller: _tit_obsController,
                  focusNode: _tit_obsFocus,
                  nextFocus: _gravarFocus,
                  tamanho: 80,
                  enabled: !_habilitado,
                ),
                const SizedBox(height: 10),

                BotoesFormulario(
                  habilitado: _habilitado,
                  inclusao: _inclusao,
                  onGravar: _gravar,
                  onExcluir: _excluir,
                  onCancelar: _cancelar,
                  onFechar: widget.onClose,
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
    _tit_idController.dispose();
    _tit_nomeController.dispose();
    _tit_docController.dispose();
    _tit_foneController.dispose();
    _tit_endController.dispose();
    _tit_baiController.dispose();
    _tit_cepController.dispose();
    _tit_cidController.dispose();
    _cid_nomeController.dispose();
    _tit_obsController.dispose();
    _tit_idFocus.dispose();
    _tit_nomeFocus.dispose();
    _tit_docFocus.dispose();
    _tit_foneFocus.dispose();
    _tit_endFocus.dispose();
    _tit_baiFocus.dispose();
    _tit_cepFocus.dispose();
    _tit_cidFocus.dispose();
    _tit_obsFocus.dispose();
    _gravarFocus.dispose();
    super.dispose();
  }
}
