import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:intl/intl.dart';

import '../models/cadeqp_models.dart';
import 'services/cadeqp_services.dart';
import 'base_cons.dart';

class ConsultaCadeqp extends BaseConsPage {
  const ConsultaCadeqp({super.key}) : super(titulo: 'Consulta de Equipamentos');

  static Future<int?> abrir(BuildContext context) {
    return showDialog<int>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const ConsultaCadeqp();
      },
    );
  }

  @override
  State<ConsultaCadeqp> createState() => _ConsultaCadeqpState();
}

class _ConsultaCadeqpState extends BaseConsState<ConsultaCadeqp> {
  final CadeqpServices _eqpServices = CadeqpServices();
  final TextEditingController _filtroController = TextEditingController();
  final ScrollController _vertical = ScrollController();
  final ScrollController _horizontal = ScrollController();
  final formato = NumberFormat('#,##0.0', 'pt_BR');
  //final formato = NumberFormat('###.##0,0', 'pt_BR');

  List<Cadeqp> _lista = [];
  List<Cadeqp> _filtrada = [];

  bool _loading = true;
  int _selectedIndex = -1;

  @override
  void dispose() {
    _filtroController.dispose();
    _vertical.dispose();
    _horizontal.dispose();
    super.dispose();
  }

  /// ===============================
  /// CARREGAR DADOS
  /// ===============================

  @override
  Future<void> carregar() async {
    setState(() => _loading = true);

    final dados = await _eqpServices.getAll();
    if (!mounted) return;

    setState(() {
      _lista = dados;
      _filtrada = dados;
      _loading = false;
      _selectedIndex = _filtrada.isNotEmpty ? 0 : -1;
    });
  }

  void _selecionar(int index) {
    if (index >= 0 && index < _filtrada.length) {
      Navigator.of(context).pop(_filtrada[index].eqp_id);
    }
  }

  /// ===============================
  /// FILTRO
  /// ===============================

  void _filtrar(String texto) {
    final t = texto.toLowerCase();

    setState(() {
      _filtrada = _lista.where((p) {
        return p.eqp_desc.toLowerCase().contains(t);
      }).toList();
      _selectedIndex = _filtrada.isNotEmpty ? 0 : -1;
    });
  }

  /// ===============================
  /// NAVEGAÇÃO
  /// ===============================

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
      Navigator.of(context).pop(_filtrada[_selectedIndex].eqp_id);
    }
  }

  /// ===============================
  /// UI
  /// ===============================

  @override
  Widget buildFiltro(BuildContext context) {
    return TextField(
      focusNode: filtroFocus,
      controller: _filtroController,
      decoration: const InputDecoration(
        labelText: 'Pesquisar...',
        prefixIcon: Icon(Icons.search),
      ),
      onChanged: _filtrar,
    );
  }

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
            minWidth: 600,
            showCheckboxColumn: false,
            columns: const [
              DataColumn2(label: Text('ID'), fixedWidth: 70, numeric: true),
              //DataColumn2(label: Text('Nome'), size: ColumnSize.L),
              //DataColumn2(label: Text('Nome'), fixedWidth: 450),
              DataColumn2(label: Text('Descrição')),
              DataColumn2(label: Text('HT/KM'), fixedWidth: 110, numeric: true),
            ],
            rows: List.generate(_filtrada.length, (index) {
              final p = _filtrada[index];
              final isSelected = index == _selectedIndex;

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
                  if (isDesktop && states.contains(WidgetState.hovered)) {
                    return Colors.grey.withOpacity(0.08);
                  }
                  return null;
                }),
                cells: [
                  DataCell(
                    Text(
                      p.eqp_id.toString(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                    ),
                  ),
                  DataCell(
                    Text(
                      p.eqp_desc,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                    ),
                  ),
                  DataCell(
                    Text(
                      //p.eqp_htkm,
                      formato.format(p.eqp_htkm),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
