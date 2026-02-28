import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cadcid_models.dart';
import '../core/api_config.dart';

class CadcidServices {
  Future<List<Cadcid>> getAll() async {
    final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/cadcid'));

    if (response.statusCode == 200) {
      final List jsonList = json.decode(response.body);
      return jsonList.map((e) => Cadcid.fromJson(e)).toList();
    } else {
      throw Exception('Erro ao buscar Cidade');
    }
  }

  Future<Cadcid?> getById(int cid_id) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/cadcid/$cid_id'),
    );

    if (response.statusCode == 200) {
      return Cadcid.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Erro ao buscar Cidade');
    }
  }

  Future<void> add(Cadcid cadcid) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/cadcid'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'cid_nome': cadcid.cid_nome, 'cid_uf': cadcid.cid_uf}),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Erro ao adicionar Cidade');
    }
  }

  Future<void> update(Cadcid cadcid) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/cadcid/${cadcid.cid_id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'cid_nome': cadcid.cid_nome, 'cid_uf': cadcid.cid_uf}),
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao atualizar Cidade');
    }
  }

  Future<void> delete(int cid_id) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/cadcid/$cid_id'),
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao excluir Cidade');
    }
  }
}
