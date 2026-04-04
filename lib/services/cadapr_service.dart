import 'dart:convert';
import 'package:http/http.dart' as http;

import '../core/api_config.dart';
import '../models/cadapr_model.dart';
import '../models/cadipr_model.dart';
import '../models/cadppr_model.dart';

class CadaprService {
  Future<Cadapr?> getById(int tr) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/cadapr/$tr'),
    );

    if (response.statusCode == 200) {
      return Cadapr.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      final body = json.decode(response.body);
      throw Exception(body['erro'] ?? 'Erro ao buscar lançamento.');
    }
  }

  Future<void> salvar({
    required Cadapr cabecalho,
    required List<Cadipr> itens,
    required List<Cadppr> parcelas,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/cadapr'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'cabecalho': cabecalho.toJson(),
        'itens': itens.map((e) => e.toJson()).toList(),
        'parcelas': parcelas.map((e) => e.toJson()).toList(),
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      final body = json.decode(response.body);
      throw Exception(body['erro'] ?? 'Erro ao salvar lançamento.');
    }
  }

  Future<void> excluir(int tr) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/cadapr/$tr'),
    );

    if (response.statusCode != 200) {
      final body = json.decode(response.body);
      throw Exception(body['erro'] ?? 'Erro ao excluir lançamento.');
    }
  }
}
