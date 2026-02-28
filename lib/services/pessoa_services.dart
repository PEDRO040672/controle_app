import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pessoa_models.dart';
import '../core/api_config.dart';

class PessoaServices {
  Future<List<Pessoa>> getAll() async {
    final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/pessoas'));

    if (response.statusCode == 200) {
      final List jsonList = json.decode(response.body);
      return jsonList.map((e) => Pessoa.fromJson(e)).toList();
    } else {
      throw Exception('Erro ao buscar pessoas');
    }
  }

  Future<Pessoa?> getById(int id) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/pessoas/$id'),
    );

    if (response.statusCode == 200) {
      return Pessoa.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Erro ao buscar pessoa');
    }
  }

  Future<void> add(Pessoa pessoa) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/pessoas'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'nome': pessoa.nome,
        'email': pessoa.email,
        'telefone': pessoa.telefone,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Erro ao adicionar pessoa');
    }
  }

  Future<void> update(Pessoa pessoa) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/pessoas/${pessoa.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'nome': pessoa.nome,
        'email': pessoa.email,
        'telefone': pessoa.telefone,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao atualizar pessoa');
    }
  }

  Future<void> delete(int id) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/pessoas/$id'),
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao excluir pessoa');
    }
  }
}
