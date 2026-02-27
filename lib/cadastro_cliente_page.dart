import 'package:flutter/material.dart';
import '../models/pessoa.dart';
import '../services/api_service.dart';
import '../widgets/campo.dart';
import '../widgets/msg.dart';
import '../widgets/botoes_formulario.dart';
import '../widgets/botao_consulta.dart';
import 'base_form.dart';
import 'consulta_pessoas.dart';

class CadastroClientePage extends BaseFormPage {
  const CadastroClientePage({super.key, required super.onClose})
    : super(titulo: 'Clientes');

  @override
  State<CadastroClientePage> createState() => _CadastroClientePageState();
}

class _CadastroClientePageState extends BaseFormState<CadastroClientePage> {
  final _codigoController = TextEditingController();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();

  final _codigoFocus = FocusNode();
  final _nomeFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _telefoneFocus = FocusNode();
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
        _codigoFocus.requestFocus();
      }
    });
  }

  // ============================================================
  // LIMPAR / CANCELAR
  // ============================================================

  void _limparCampos() {
    _codigoController.clear();
    _nomeController.clear();
    _emailController.clear();
    _telefoneController.clear();
  }

  void _cancelar() {
    FocusScope.of(context).unfocus();

    setState(() {
      _inclusao = true;
      _habilitado = true;
      _limparCampos();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _codigoFocus.requestFocus();
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

  Future<void> _carregarPessoa() async {
    final codigo = int.tryParse(_codigoController.text) ?? 0;

    if (codigo <= 0) {
      setState(() {
        _inclusao = true;
        _habilitado = false;
        _limparCampos();
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _nomeFocus.requestFocus();
      });
      return;
    }

    _iniciarCarregamento();

    try {
      final pessoa = await ApiService.getPessoaById(codigo);

      if (!mounted) return;

      if (pessoa != null) {
        setState(() {
          _inclusao = false;
          _habilitado = false;
          _nomeController.text = pessoa.nome;
          _emailController.text = pessoa.email;
          _telefoneController.text = pessoa.telefone;
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _nomeFocus.requestFocus();
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
    final codigo = int.tryParse(_codigoController.text) ?? 0;

    final pessoa = Pessoa(
      id: codigo,
      nome: _nomeController.text,
      email: _emailController.text,
      telefone: _telefoneController.text,
    );

    _iniciarCarregamento();

    try {
      if (codigo == 0) {
        await ApiService.addPessoa(pessoa);
      } else {
        await ApiService.updatePessoa(pessoa);
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
    final codigo = int.tryParse(_codigoController.text) ?? 0;
    if (codigo <= 0) return;

    _iniciarCarregamento();

    try {
      await ApiService.deletePessoa(codigo);

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

    final int? idSelecionado = await ConsultaPessoas.abrir(context);

    if (idSelecionado != null) {
      _codigoController.text = idSelecionado.toString();
      await _carregarPessoa();
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
                    controller: _codigoController,
                    focusNode: _codigoFocus,
                    nextFocus: _nomeFocus,
                    tamanho: 5,
                    zeroEsquerda: true,
                    enabled: _habilitado,
                    onSubmitted: () async {
                      await _carregarPessoa();
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
                controller: _nomeController,
                focusNode: _nomeFocus,
                nextFocus: _emailFocus,
                tamanho: 50,
                enabled: !_habilitado,
              ),
              const SizedBox(height: 8),
              Campo(
                tipo: TipoCampo.texto,
                titulo: 'Email',
                controller: _emailController,
                focusNode: _emailFocus,
                nextFocus: _telefoneFocus,
                tamanho: 80,
                enabled: !_habilitado,
              ),
              const SizedBox(height: 8),
              Campo(
                tipo: TipoCampo.mascara,
                titulo: 'Telefone',
                controller: _telefoneController,
                focusNode: _telefoneFocus,
                nextFocus: _gravarFocus,
                mascara: '(99) ?9999-9999',
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
    _codigoController.dispose();
    _nomeController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _codigoFocus.dispose();
    _nomeFocus.dispose();
    _emailFocus.dispose();
    _telefoneFocus.dispose();
    _gravarFocus.dispose();
    super.dispose();
  }
}
