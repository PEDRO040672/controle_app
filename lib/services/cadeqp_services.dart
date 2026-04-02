import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cadeqp_models.dart';
import '../core/api_config.dart';

class CadeqpServices {
  Future<List<Cadeqp>> getAll() async {
    final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/cadeqp'));

    if (response.statusCode == 200) {
      final List jsonList = json.decode(response.body);
      return jsonList.map((e) => Cadeqp.fromJson(e)).toList();
    } else {
      final body = json.decode(response.body);
      throw Exception(body['erro'] ?? 'Erro ao buscar Equipamento.');
    }
  }

  Future<Cadeqp?> getById(int eqp_id) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/cadeqp/$eqp_id'),
    );

    if (response.statusCode == 200) {
      return Cadeqp.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      final body = json.decode(response.body);
      throw Exception(body['erro'] ?? 'Erro ao buscar Equipamento.');
    }
  }

  Future<void> add(Cadeqp cadeqp) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/cadeqp'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(cadeqp.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      final body = json.decode(response.body);
      throw Exception(body['erro'] ?? 'Erro ao adicionar Equipamento.');
    }
  }

  Future<void> update(Cadeqp cadeqp) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/cadeqp/${cadeqp.eqp_id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(cadeqp.toJson()),
    );

    if (response.statusCode != 200) {
      final body = json.decode(response.body);
      throw Exception(body['erro'] ?? 'Erro ao atualizar Equipamento.');
    }
  }

  Future<void> delete(int eqp_id) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/cadeqp/$eqp_id'),
    );

    if (response.statusCode != 200) {
      final body = json.decode(response.body);
      throw Exception(body['erro'] ?? 'Erro ao excluir Equipamento.');
    }
  }
}
