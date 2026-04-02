import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cadope_models.dart';
import '../core/api_config.dart';

class CadopeServices {
  Future<List<Cadope>> getAll() async {
    final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/cadope'));

    if (response.statusCode == 200) {
      final List jsonList = json.decode(response.body);
      return jsonList.map((e) => Cadope.fromJson(e)).toList();
    } else {
      final body = json.decode(response.body);
      throw Exception(body['erro'] ?? 'Erro ao buscar Operador.');
    }
  }

  Future<Cadope?> getById(int ope_id) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/cadope/$ope_id'),
    );

    if (response.statusCode == 200) {
      return Cadope.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      final body = json.decode(response.body);
      throw Exception(body['erro'] ?? 'Erro ao buscar Operador.');
    }
  }

  Future<void> add(Cadope cadope) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/cadope'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(cadope.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      final body = json.decode(response.body);
      throw Exception(body['erro'] ?? 'Erro ao adicionar Operador.');
    }
  }

  Future<void> update(Cadope cadope) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/cadope/${cadope.ope_id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(cadope.toJson()),
    );

    if (response.statusCode != 200) {
      final body = json.decode(response.body);
      throw Exception(body['erro'] ?? 'Erro ao atualizar Operador.');
    }
  }

  Future<void> delete(int ope_id) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/cadope/$ope_id'),
    );

    if (response.statusCode != 200) {
      final body = json.decode(response.body);
      throw Exception(body['erro'] ?? 'Erro ao excluir Operador.');
    }
  }
}
