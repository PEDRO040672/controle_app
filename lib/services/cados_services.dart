import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cados_models.dart';
import '../core/api_config.dart';

class CadosServices {
  Future<List<Cados>> getAll() async {
    final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/cados'));

    if (response.statusCode == 200) {
      final List jsonList = json.decode(response.body);
      return jsonList.map((e) => Cados.fromJson(e)).toList();
    } else {
      final body = json.decode(response.body);
      throw Exception(body['erro'] ?? 'Erro ao buscar OS.');
    }
  }

  Future<Cados?> getById(int os_tr) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/cados/$os_tr'),
    );
    if (response.statusCode == 200) {
      return Cados.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      final body = json.decode(response.body);
      throw Exception(body['erro'] ?? 'Erro ao buscar OS.');
    }
  }

  Future<void> add(Cados cados) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/cados'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(cados.toJson()),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      final body = json.decode(response.body);
      throw Exception(body['erro'] ?? 'Erro ao adicionar OS.');
    }
  }

  Future<void> update(Cados cados) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/cados/${cados.os_tr}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(cados.toJson()),
    );
    if (response.statusCode != 200) {
      final body = json.decode(response.body);
      throw Exception(body['erro'] ?? 'Erro ao atualizar OS.');
    }
  }

  Future<void> delete(int os_tr) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/cados/$os_tr'),
    );
    if (response.statusCode != 200) {
      final body = json.decode(response.body);
      throw Exception(body['erro'] ?? 'Erro ao excluir OS.');
    }
  }
}
