import 'package:flutter/material.dart';
import '../models/cadcid_models.dart';
import 'services/cadcid_services.dart';
import '../widgets/campo.dart';
import '../widgets/msg.dart';
import '../widgets/botoes_formulario.dart';
import '../widgets/botao_consulta.dart';
import 'base_form.dart';
import 'con_cid.dart';

class ForCidPage extends BaseFormPage {
  const ForCidPage({super.key, required super.onClose})
    : super(titulo: 'Cidades');

  @override
  State<ForCidPage> createState() => _ForCidState();
}

class _ForCidState extends BaseFormState<ForCidPage> {
  final CadcidServices _services = CadcidServices();

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
  // LIMPAR / CANCELAR
  // ============================================================

  void _limparCampos() {
    _cid_idController.clear();
    _cid_nomeController.clear();
    _cid_ufController.clear();
  }

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
      final cadcid = await _services.getById(codigo);
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
    final codigo = int.tryParse(_cid_idController.text) ?? 0;

    final cadcid = Cadcid(
      cid_id: codigo,
      cid_nome: _cid_nomeController.text,
      cid_uf: _cid_ufController.text,
    );

    _iniciarCarregamento();

    try {
      if (codigo == 0) {
        await _services.add(cadcid);
      } else {
        await _services.update(cadcid);
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

    final int? idSelecionado = await ConsultaCadcid.abrir(context);

    if (idSelecionado != null) {
      _cid_idController.text = idSelecionado.toString();
      await _carregarCadcid();
    }
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget buildBody(BuildContext context) {
    return Stack(
      children: [
        FocusTraversalGroup(
          policy: OrderedTraversalPolicy(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Campo(
                    tipo: TipoCampo.inteiro,
                    titulo: 'Código',
                    controller: _cid_idController,
                    focusNode: _cid_idFocus,
                    nextFocus: _cid_nomeFocus,
                    tamanho: 5,
                    zeroEsquerda: true,
                    enabled: _habilitado,
                    onSubmitted: () async {
                      await _carregarCadcid();
                      return true;
                    },
                  ),
                  const SizedBox(width: 8),
                  BotaoConsulta(onPressed: _habilitado ? _abrirConsulta : null),
                ],
              ),
              const SizedBox(height: 8),
              Campo(
                tipo: TipoCampo.texto,
                titulo: 'Nome',
                controller: _cid_nomeController,
                focusNode: _cid_nomeFocus,
                nextFocus: _cid_ufFocus,
                tamanho: 50,
                enabled: !_habilitado,
              ),
              const SizedBox(height: 8),
              Campo(
                tipo: TipoCampo.texto,
                titulo: 'UF',
                controller: _cid_ufController,
                focusNode: _cid_ufFocus,
                nextFocus: _gravarFocus,
                tamanho: 2,
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
