import 'dart:convert';
import 'package:http/http.dart' as http;

import '../core/api_config.dart';
import '../models/cadbpr_model.dart';

class CadbprService {
  Future<List<Cadbpr>> listar(int tr, int pc) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/cadbpr/$tr/$pc'),
    );

    if (response.statusCode == 200) {
      final List jsonList = json.decode(response.body);
      return jsonList.map((e) => Cadbpr.fromJson(e)).toList();
    } else {
      final body = json.decode(response.body);
      throw Exception(body['erro'] ?? 'Erro ao buscar baixas.');
    }
  }

  Future<void> inserir(Cadbpr baixa) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/cadbpr'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(baixa.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      final body = json.decode(response.body);
      throw Exception(body['erro'] ?? 'Erro ao inserir baixa.');
    }
  }

  Future<void> excluir(int tr, int pc, int it) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/cadbpr/$tr/$pc/$it'),
    );

    if (response.statusCode != 200) {
      final body = json.decode(response.body);
      throw Exception(body['erro'] ?? 'Erro ao excluir baixa.');
    }
  }
}
