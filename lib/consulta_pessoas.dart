import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';

import '../models/pessoa_models.dart';
import 'services/pessoa_services.dart';
import 'base_cons.dart';

class ConsultaPessoas extends BaseConsPage {
  const ConsultaPessoas({super.key}) : super(titulo: 'Consulta de Pessoas');

  static Future<int?> abrir(BuildContext context) {
    return Navigator.of(context, rootNavigator: true).push<int>(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: false,
        pageBuilder: (_, __, ___) => const ConsultaPessoas(),
      ),
    );
  }

  @override
  State<ConsultaPessoas> createState() => _ConsultaPessoasState();
}

class _ConsultaPessoasState extends BaseConsState<ConsultaPessoas> {
  final PessoaServices _services = PessoaServices();
  final TextEditingController _filtroController = TextEditingController();
  final ScrollController _vertical = ScrollController();
  final ScrollController _horizontal = ScrollController();

  List<Pessoa> _lista = [];
  List<Pessoa> _filtrada = [];

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

    final dados = await _services.getAll();
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
      Navigator.of(context).pop(_filtrada[index].id);
    }
  }

  /// ===============================
  /// FILTRO
  /// ===============================

  void _filtrar(String texto) {
    final t = texto.toLowerCase();

    setState(() {
      _filtrada = _lista.where((p) {
        return p.nome.toLowerCase().contains(t) ||
            p.email.toLowerCase().contains(t) ||
            p.id.toString().contains(t);
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
      Navigator.of(context).pop(_filtrada[_selectedIndex].id);
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
        child: DataTable2(
          scrollController: _vertical,
          horizontalScrollController: _horizontal,
          columnSpacing: 24,
          horizontalMargin: 12,
          dataRowHeight: 42,
          headingRowHeight: 46,
          minWidth: 900,
          showCheckboxColumn: false,
          columns: const [
            DataColumn2(label: Text('ID'), fixedWidth: 70, numeric: true),
            DataColumn2(label: Text('Nome'), size: ColumnSize.L),
            DataColumn2(label: Text('Email'), size: ColumnSize.L),
            DataColumn2(label: Text('Telefone'), size: ColumnSize.M),
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
                    p.id.toString(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                  ),
                ),
                DataCell(
                  Text(
                    p.nome,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                  ),
                ),
                DataCell(
                  Text(
                    p.email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                  ),
                ),
                DataCell(
                  Text(
                    p.telefone,
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
    );
  }
}
