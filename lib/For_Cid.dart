import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'widgets/botoes.dart';
import '../widgets/campo.dart';
import '../widgets/msg.dart';
import '../models/cadcid_models.dart';
import 'services/cadcid_services.dart';
import 'base_form.dart';
import 'con_cid.dart';

class ForCidPage extends BaseFormPage {
  const ForCidPage({super.key, required super.onClose})
    : super(titulo: 'Cidades');

  @override
  State<ForCidPage> createState() => _ForCidState();
}

class _ForCidState extends BaseFormState<ForCidPage> {
  final CadcidServices _cidServices = CadcidServices();

  final _cid_idController = TextEditingController();
  final _cid_nomeController = TextEditingController();
  final _cid_ufController = TextEditingController();

  final _cid_idFocus = FocusNode();
  final _cid_nomeFocus = FocusNode();
  final _cid_ufFocus = FocusNode();
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
        _cid_idFocus.requestFocus();
      }
    });
  }

  // ============================================================
  // LIMPAR
  // ============================================================
  void _limparCampos() {
    _cid_idController.clear();
    _cid_nomeController.clear();
    _cid_ufController.clear();
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
      if (mounted) _cid_idFocus.requestFocus();
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
  Future<void> _carregarCadcid() async {
    final codigo = int.tryParse(_cid_idController.text) ?? 0;
    if (codigo <= 0) {
      setState(() {
        _inclusao = true;
        _habilitado = false;
        _limparCampos();
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _cid_nomeFocus.requestFocus();
      });
      return;
    }
    _iniciarCarregamento();
    try {
      final cadcid = await _cidServices.getById(codigo);
      if (!mounted) return;
      if (cadcid != null) {
        setState(() {
          _inclusao = false;
          _habilitado = false;
          _cid_nomeController.text = cadcid.cid_nome;
          _cid_ufController.text = cadcid.cid_uf;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _cid_nomeFocus.requestFocus();
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
    if (!await _valid_cid_nome()) return;
    if (!await _valid_cid_uf()) return;

    //--------[ Se PASSOU nas Validações, CONTINUA ]------------
    final codigo = int.tryParse(_cid_idController.text) ?? 0;
    final cadcid = Cadcid(
      cid_id: codigo,
      cid_nome: _cid_nomeController.text,
      cid_uf: _cid_ufController.text,
    );
    _iniciarCarregamento();
    try {
      if (codigo == 0) {
        await _cidServices.add(cadcid);
      } else {
        await _cidServices.update(cadcid);
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
    final codigo = int.tryParse(_cid_idController.text) ?? 0;
    if (codigo <= 0) return;
    _iniciarCarregamento();
    try {
      await _cidServices.delete(codigo);
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

    final int? idSelecionado = await ConsultaCadcid.abrir(context);

    if (idSelecionado != null) {
      _cid_idController.text = idSelecionado.toString();
      await _carregarCadcid();
    }
  }

  //========================[ _valid_cid_nome ]===========
  Future<bool> _valid_cid_nome() async {
    _cid_nomeController.text = _cid_nomeController.text.trim();
    if (_cid_nomeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('O campo NOME está vazio.'),
          duration: Duration(seconds: 2),
        ),
      );
      _cid_nomeFocus.requestFocus(); // volta foco no campo
      return false;
    }
    return true;
  }

  //========================[ _valid_cid_uf ]===========
  Future<bool> _valid_cid_uf() async {
    _cid_ufController.text = _cid_ufController.text.trim();
    if (_cid_ufController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('O campo UF está vazio.'),
          duration: Duration(seconds: 2),
        ),
      );
      _cid_ufFocus.requestFocus(); // volta foco no campo
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
            if (_habilitado && _cid_idFocus.hasFocus) {
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
                  controller: _cid_idController,
                  focusNode: _cid_idFocus,
                  nextFocus: _cid_nomeFocus,
                  tamanho: 5,
                  //zeroEsquerda: true,
                  enabled: _habilitado,
                  onDoubleTap: () {
                    _abrirConsulta();
                  },
                  onSubmitted: () async {
                    await _carregarCadcid();
                    return true;
                  },
                ),
                const SizedBox(height: 10),
                Campo(
                  tipo: TipoCampo.texto,
                  titulo: 'Nome',
                  controller: _cid_nomeController,
                  focusNode: _cid_nomeFocus,
                  onSubmitted: _valid_cid_nome,
                  nextFocus: _cid_ufFocus,
                  tamanho: 50,
                  enabled: !_habilitado,
                ),
                const SizedBox(height: 10),
                Campo(
                  tipo: TipoCampo.uf,
                  titulo: 'UF',
                  controller: _cid_ufController,
                  focusNode: _cid_ufFocus,
                  onSubmitted: _valid_cid_uf,
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
    _cid_idController.dispose();
    _cid_nomeController.dispose();
    _cid_ufController.dispose();
    _cid_idFocus.dispose();
    _cid_nomeFocus.dispose();
    _cid_ufFocus.dispose();
    _gravarFocus.dispose();
    super.dispose();
  }
}
