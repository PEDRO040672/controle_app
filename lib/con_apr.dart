import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:intl/intl.dart';

import '../models/cadapr_models.dart';
import 'services/cadapr_services.dart';
import 'base_cons.dart';
import '../widgets/campo.dart';

class ConsultaCadapr extends BaseConsPage {
  const ConsultaCadapr({super.key}) : super(titulo: 'Consulta Financeiro');

  static Future<int?> abrir(BuildContext context) {
    return showDialog<int>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const ConsultaCadapr();
      },
    );
  }

  @override
  State<ConsultaCadapr> createState() => _ConsultaCadaprState();
}

class _ConsultaCadaprState extends BaseConsState<ConsultaCadapr> {
  final CadaprServices _services = CadaprServices();

  final ScrollController _vertical = ScrollController();
  final ScrollController _horizontal = ScrollController();

  final formato = NumberFormat('#,##0.00', 'pt_BR');
  final formatohtkm = NumberFormat('#,##0.0', 'pt_BR');
  final formatoData = DateFormat('dd/MM/yyyy');

  List<Cadapr> _lista = [];
  List<Cadapr> _filtrada = [];

  bool _loading = true;
  int _selectedIndex = -1;

  /// FILTROS
  final _tipoController = TextEditingController(text: 'Todas');
  final _titularController = TextEditingController();
  final _situacaoController = TextEditingController(text: 'Todas');
  final _dataIniController = TextEditingController();
  final _dataFimController = TextEditingController();
  final _totalController = TextEditingController();

  final _tipoFocus = FocusNode();
  final _titularFocus = FocusNode();
  final _situacaoFocus = FocusNode();
  final _dataIniFocus = FocusNode();
  final _dataFimFocus = FocusNode();

  @override
  void initState() {
    super.initState();

    final hoje = DateTime.now();
    final dataInicial = DateTime(hoje.year, hoje.month, 1);

    _dataIniController.text = DateFormat('dd/MM/yyyy').format(dataInicial);
    _dataFimController.text = DateFormat('dd/MM/yyyy').format(hoje);
  }

  @override
  void dispose() {
    _vertical.dispose();
    _horizontal.dispose();
    super.dispose();
  }

  /// ==========================================
  /// CARREGAR
  /// ==========================================
  @override
  Future<void> carregar() async {
    setState(() => _loading = true);

    final dados = await _services.getAll();
    if (!mounted) return;

    setState(() {
      _lista = dados;
      _filtrada = dados;
      _loading = false;
      _selectedIndex = _filtrada.isNotEmpty ? 0 : -1;
    });

    _filtrar();
  }

  /// ==========================================
  /// TOTAL
  /// ==========================================
  void _calcularTotal() {
    double total = 0;
    for (var item in _filtrada) {
      total += item.apr_vltot;
    }

    _totalController.text = Campo.doubleText(total, '999.999.999,99');
  }

  /// ==========================================
  /// FILTRAR
  /// ==========================================
  void _filtrar() {
    final tipo = _tipoController.text;
    final nome = _titularController.text.toLowerCase();
    final situ = _situacaoController.text;

    DateTime? dataIni;
    DateTime? dataFim;

    if (Campo.validaData(_dataIniController.text)) {
      final p = _dataIniController.text.split('/');
      dataIni = DateTime(int.parse(p[2]), int.parse(p[1]), int.parse(p[0]));
    }

    if (Campo.validaData(_dataFimController.text)) {
      final p = _dataFimController.text.split('/');
      dataFim = DateTime(int.parse(p[2]), int.parse(p[1]), int.parse(p[0]));
    }

    setState(() {
      _filtrada = _lista.where((p) {
        bool ok = true;

        if (tipo != 'Todas') {
          ok &= p.apr_tipo == tipo;
        }

        if (nome.isNotEmpty) {
          ok &= (p.tit_nome ?? '').toLowerCase().contains(nome);
        }

        if (situ != 'Todas') {
          ok &= p.apr_situ == situ;
        }

        final data = DateTime(
          p.apr_data.year,
          p.apr_data.month,
          p.apr_data.day,
        );

        if (dataIni != null) ok &= !data.isBefore(dataIni);
        if (dataFim != null) ok &= !data.isAfter(dataFim);

        return ok;
      }).toList();

      _selectedIndex = _filtrada.isNotEmpty ? 0 : -1;
    });

    _calcularTotal();
  }

  void _limpar() {
    _tipoController.text = 'Todas';
    _titularController.clear();
    _situacaoController.text = 'Todas';
    _dataIniController.clear();
    _dataFimController.clear();
    _filtrar();
  }

  /// ==========================================
  /// NAVEGAÇÃO
  /// ==========================================
  @override
  void mover(int delta) {
    if (_filtrada.isEmpty) return;

    setState(() {
      _selectedIndex = (_selectedIndex + delta).clamp(0, _filtrada.length - 1);
    });

    _vertical.animateTo(
      _selectedIndex * 42,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
    );
  }

  @override
  void selecionarAtual() {
    if (_selectedIndex >= 0) {
      Navigator.of(context).pop(_filtrada[_selectedIndex].apr_tr);
    }
  }

  /// ==========================================
  /// FILTRO UI
  /// ==========================================
  @override
  Widget buildFiltro(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Campo(
          tipo: TipoCampo.lista,
          titulo: 'Tipo',
          controller: _tipoController,
          focusNode: _tipoFocus,
          nextFocus: _titularFocus,
          lista: 'Todas,OS,A_Pagar,A_Receber',
          onChanged: (_) => _filtrar(),
        ),
        Campo(
          tipo: TipoCampo.texto,
          titulo: 'Titular',
          controller: _titularController,
          focusNode: _titularFocus,
          nextFocus: _situacaoFocus,
          tamanho: 20,
          onChanged: (_) => _filtrar(),
        ),
        Campo(
          tipo: TipoCampo.lista,
          titulo: 'Situação',
          controller: _situacaoController,
          focusNode: _situacaoFocus,
          nextFocus: _dataIniFocus,
          lista: 'Todas,Aberto,Fechado,Quitado,Parcial',
          onChanged: (_) => _filtrar(),
        ),
        Campo(
          tipo: TipoCampo.data,
          titulo: 'Data Inicial',
          controller: _dataIniController,
          focusNode: _dataIniFocus,
          nextFocus: _dataFimFocus,
          onChanged: (_) => _filtrar(),
        ),
        Campo(
          tipo: TipoCampo.data,
          titulo: 'Data Final',
          controller: _dataFimController,
          focusNode: _dataFimFocus,
          onChanged: (_) => _filtrar(),
        ),
        Campo(
          tipo: TipoCampo.double,
          titulo: 'Total',
          controller: _totalController,
          focusNode: FocusNode(),
          enabled: false,
          mascara: '99.999.999,99',
        ),
        SizedBox(
          height: 38,
          child: ElevatedButton.icon(
            onPressed: _filtrar,
            icon: const Icon(Icons.search, size: 18),
            label: const Text('Filtrar'),
          ),
        ),
        SizedBox(
          height: 38,
          child: ElevatedButton.icon(
            onPressed: _limpar,
            icon: const Icon(Icons.clear, size: 18),
            label: const Text('Limpar'),
          ),
        ),
      ],
    );
  }

  /// ==========================================
  /// TABELA
  /// ==========================================
  @override
  Widget buildTabela(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return DataTable2(
      scrollController: _vertical,
      horizontalScrollController: _horizontal,
      dataRowHeight: 42,
      headingRowHeight: 46,
      showCheckboxColumn: false,
      minWidth: 1200,
      columns: const [
        DataColumn2(label: Text('TR'), numeric: true, fixedWidth: 70),
        DataColumn2(label: Text('Tipo'), fixedWidth: 160),
        DataColumn2(label: Text('Situação'), fixedWidth: 160),
        DataColumn2(label: Text('Data'), fixedWidth: 160),
        DataColumn2(
          label: Text('Titular'),
          fixedWidth: 150,
          size: ColumnSize.L,
        ),
        DataColumn2(
          label: Text('Equipamento'),
          fixedWidth: 150,
          size: ColumnSize.L,
        ),
        DataColumn2(label: Text('HT/KM'), numeric: true),
        DataColumn2(label: Text('Valor'), numeric: true),
      ],
      rows: List.generate(_filtrada.length, (index) {
        final p = _filtrada[index];
        final isSelected = index == _selectedIndex;

        return DataRow2(
          selected: isSelected,
          onTap: () => setState(() => _selectedIndex = index),
          onDoubleTap: () {
            _selectedIndex = index;
            selecionarAtual();
          },
          cells: [
            DataCell(Text(p.apr_tr.toString())),
            DataCell(Text(p.apr_tipo)),
            DataCell(Text(p.apr_situ)),
            DataCell(Text(formatoData.format(p.apr_data))),
            DataCell(
              Text(
                p.tit_nome ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
              ),
            ),
            DataCell(
              Text(
                p.eqp_desc ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
              ),
            ),
            DataCell(Text(formatohtkm.format(p.apr_htkm))),
            DataCell(Text(formato.format(p.apr_vltot))),
          ],
        );
      }),
    );
  }
}
