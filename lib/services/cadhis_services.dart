import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cadhis_models.dart';
import '../core/api_config.dart';

class CadhisServices {
  Future<List<Cadhis>> getAll() async {
    final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/cadhis'));

    if (response.statusCode == 200) {
      final List jsonList = json.decode(response.body);
      return jsonList.map((e) => Cadhis.fromJson(e)).toList();
    } else {
      final body = json.decode(response.body);
      throw Exception(body['erro'] ?? 'Erro ao buscar Histórico.');
    }
  }

  Future<Cadhis?> getById(int his_id) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/cadhis/$his_id'),
    );

    if (response.statusCode == 200) {
      return Cadhis.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      final body = json.decode(response.body);
      throw Exception(body['erro'] ?? 'Erro ao buscar Histórico.');
    }
  }

  Future<void> add(Cadhis cadhis) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/cadhis'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(cadhis.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      final body = json.decode(response.body);
      throw Exception(body['erro'] ?? 'Erro ao adicionar Histórico.');
    }
  }

  Future<void> update(Cadhis cadhis) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/cadhis/${cadhis.his_id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(cadhis.toJson()),
    );

    if (response.statusCode != 200) {
      final body = json.decode(response.body);
      throw Exception(body['erro'] ?? 'Erro ao atualizar Histórico.');
    }
  }

  Future<void> delete(int his_id) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/cadhis/$his_id'),
    );

    if (response.statusCode != 200) {
      final body = json.decode(response.body);
      throw Exception(body['erro'] ?? 'Erro ao excluir Histórico.');
    }
  }
}
