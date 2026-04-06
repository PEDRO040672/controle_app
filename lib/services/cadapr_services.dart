import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cadapr_models.dart';
import '../core/api_config.dart';

class CadaprServices {
  Future<List<Cadapr>> getAll() async {
    final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/cadapr'));

    if (response.statusCode == 200) {
      final List jsonList = json.decode(response.body);
      return jsonList.map((e) => Cadapr.fromJson(e)).toList();
    } else {
      final body = json.decode(response.body);
      throw Exception(body['erro'] ?? 'Erro ao buscar financeiro.');
    }
  }

  Future<Map<String, dynamic>?> getById(int apr_tr) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/cadapr/$apr_tr'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 404) {
      return null;
    } else {
      final body = json.decode(response.body);
      throw Exception(body['erro'] ?? 'Erro ao buscar registro.');
    }
  }

  Future<void> add({
    required Map<String, dynamic> cabecalho,
    required List<Map<String, dynamic>> itens,
    required List<Map<String, dynamic>> parcelas,
    required bool quitarTotal,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/cadapr'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        "cabecalho": cabecalho,
        "itens": itens,
        "parcelas": parcelas,
        "quitar_total": quitarTotal,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      final body = json.decode(response.body);
      throw Exception(body['erro'] ?? 'Erro ao adicionar.');
    }
  }

  Future<void> update({
    required int apr_tr,
    required Map<String, dynamic> cabecalho,
    required List<Map<String, dynamic>> itens,
    required List<Map<String, dynamic>> parcelas,
    required bool quitarTotal,
  }) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/cadapr/$apr_tr'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        "cabecalho": cabecalho,
        "itens": itens,
        "parcelas": parcelas,
        "quitar_total": quitarTotal,
      }),
    );

    if (response.statusCode != 200) {
      final body = json.decode(response.body);
      throw Exception(body['erro'] ?? 'Erro ao atualizar.');
    }
  }

  Future<void> delete(int apr_tr) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/cadapr/$apr_tr'),
    );

    if (response.statusCode != 200) {
      final body = json.decode(response.body);
      throw Exception(body['erro'] ?? 'Erro ao excluir.');
    }
  }
}
