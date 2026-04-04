import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:intl/intl.dart';

import '../models/cados_models.dart';
import 'services/cados_services.dart';
import 'base_cons.dart';
import '../widgets/campo.dart';

class ConsultaCados extends BaseConsPage {
  const ConsultaCados({super.key}) : super(titulo: 'Consulta de OS');

  static Future<int?> abrir(BuildContext context) {
    return showDialog<int>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const ConsultaCados();
      },
    );
  }

  @override
  State<ConsultaCados> createState() => _ConsultaCadosState();
}

class _ConsultaCadosState extends BaseConsState<ConsultaCados> {
  final CadosServices _osServices = CadosServices();

  final ScrollController _vertical = ScrollController();
  final ScrollController _horizontal = ScrollController();

  final formato = NumberFormat('#,##0.00', 'pt_BR');
  final formatoData = DateFormat('dd/MM/yyyy');

  List<Cados> _lista = [];
  List<Cados> _filtrada = [];

  bool _loading = true;
  int _selectedIndex = -1;

  /// CONTROLLERS FILTRO
  final _titularController = TextEditingController();
  final _situacaoController = TextEditingController(text: 'Todas');
  final _dataIniController = TextEditingController();
  final _dataFimController = TextEditingController();
  final _totalController = TextEditingController();

  final _titularFocus = FocusNode();
  final _situacaoFocus = FocusNode();
  final _dataIniFocus = FocusNode();
  final _dataFimFocus = FocusNode();

  @override
  void dispose() {
    _vertical.dispose();
    _horizontal.dispose();

    _titularController.dispose();
    _situacaoController.dispose();
    _dataIniController.dispose();
    _dataFimController.dispose();
    _totalController.dispose();

    super.dispose();
  }

  //==================================================
  @override
  void initState() {
    super.initState();
    final hoje = DateTime.now();
    final dataInicial = DateTime(hoje.year, hoje.month, 1);
    _dataIniController.text = DateFormat('dd/MM/yyyy').format(dataInicial);
    _dataFimController.text = DateFormat('dd/MM/yyyy').format(hoje);
  }

  /// CARREGAR
  @override
  Future<void> carregar() async {
    setState(() => _loading = true);

    final dados = await _osServices.getAll();
    if (!mounted) return;

    setState(() {
      _lista = dados;
      _filtrada = dados;
      _loading = false;
      _selectedIndex = _filtrada.isNotEmpty ? 0 : -1;
    });

    _filtrar(); // <-- AQUI
  }

  /// TOTAL
  void _calcularTotal() {
    double total = 0;
    for (var item in _filtrada) {
      total += item.os_vltots;
    }

    _totalController.text = Campo.doubleText(total, '999.999.999,99');
  }

  /// FILTRO
  void _filtrar() {
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

        if (nome.isNotEmpty) {
          ok &= p.tit_nome.toLowerCase().contains(nome);
        }

        if (situ.isNotEmpty && situ != 'Todas') {
          ok &= p.os_situ == situ;
        }

        final data = DateTime(p.os_data.year, p.os_data.month, p.os_data.day);

        if (dataIni != null) {
          ok &= !data.isBefore(dataIni);
        }

        if (dataFim != null) {
          ok &= !data.isAfter(dataFim);
        }
        return ok;
      }).toList();

      _selectedIndex = _filtrada.isNotEmpty ? 0 : -1;
    });

    _calcularTotal();
  }

  void _limpar() {
    _titularController.clear();
    _situacaoController.text = 'Todas';
    _dataIniController.clear();
    _dataFimController.clear();
    //final hoje = DateTime.now();
    //final dataInicial = DateTime(hoje.year, hoje.month, 1);
    //_dataIniController.text = DateFormat('dd/MM/yyyy').format(dataInicial);
    //_dataFimController.text = DateFormat('dd/MM/yyyy').format(hoje);
    _filtrar();
  }

  /// NAVEGAÇÃO
  void _selecionar(int index) {
    if (index >= 0 && index < _filtrada.length) {
      Navigator.of(context).pop(_filtrada[index].os_tr);
    }
  }

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
    if (_selectedIndex >= 0 && _selectedIndex < _filtrada.length) {
      Navigator.of(context).pop(_filtrada[_selectedIndex].os_tr);
    }
  }

  /// FILTRO UI
  @override
  Widget buildFiltro(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.spaceBetween, // 👈 JUSTIFICADO
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Campo(
          tipo: TipoCampo.texto,
          titulo: 'Titular',
          controller: _titularController,
          focusNode: _titularFocus,
          nextFocus: _situacaoFocus,
          tamanho: 24,
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
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              minimumSize: const Size(0, 38),
            ),
          ),
        ),
        SizedBox(
          height: 38,
          //child: OutlinedButton.icon(
          child: ElevatedButton.icon(
            onPressed: _limpar,
            icon: const Icon(Icons.clear, size: 18),
            label: const Text('Limpar'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              minimumSize: const Size(0, 38),
            ),
          ),
        ),
      ],
    );
  }

  /// TABELA
  @override
  Widget buildTabela(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scrollbar(
      controller: _vertical,
      thumbVisibility: true,
      trackVisibility: true,
      child: Scrollbar(
        controller: _horizontal,
        thumbVisibility: true,
        trackVisibility: true,
        notificationPredicate: (notification) =>
            notification.metrics.axis == Axis.horizontal,
        child: Theme(
          data: Theme.of(context).copyWith(
            dataTableTheme: DataTableThemeData(
              dataTextStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontFamily: 'RobotoMono',
                fontSize: 15,
              ),
              headingTextStyle: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(
                    fontFamily: 'RobotoMono',
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          child: DataTable2(
            scrollController: _vertical,
            horizontalScrollController: _horizontal,
            columnSpacing: 24,
            horizontalMargin: 12,
            dataRowHeight: 42,
            headingRowHeight: 46,
            minWidth: 750,
            showCheckboxColumn: false,
            columns: const [
              DataColumn2(label: Text('TR'), fixedWidth: 70, numeric: true),
              DataColumn2(label: Text('Situação'), fixedWidth: 120),
              DataColumn2(label: Text('Data'), fixedWidth: 150),
              DataColumn2(label: Text('Titular'), fixedWidth: 210),
              DataColumn2(label: Text('Vl. OS'), numeric: true),
            ],
            rows: List.generate(_filtrada.length, (index) {
              final p = _filtrada[index];
              final isSelected = index == _selectedIndex;

              Widget cell(String text) {
                return Tooltip(
                  message: text,
                  child: Text(
                    text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                  ),
                );
              }

              return DataRow2(
                selected: isSelected,
                onTap: () => setState(() => _selectedIndex = index),
                onDoubleTap: () {
                  setState(() => _selectedIndex = index);
                  _selecionar(index);
                },
                color: WidgetStateProperty.resolveWith<Color?>((states) {
                  if (isSelected) {
                    return Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.18);
                  }
                  return null;
                }),
                cells: [
                  DataCell(cell(p.os_tr.toString())),
                  DataCell(cell(p.os_situ)),
                  DataCell(cell(formatoData.format(p.os_data))),
                  DataCell(cell(p.tit_nome)),
                  DataCell(cell(formato.format(p.os_vltots))),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
