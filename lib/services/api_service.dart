import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pessoa.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiService {
  static String get baseUrl {
    const useRailway = true; // trocar para false para testar localmente
    if (useRailway) {
      return 'https://controle-backend-production.up.railway.app';
    } else if (kIsWeb) {
      return 'http://localhost:3000';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000';
    } else {
      return 'http://localhost:3000';
    }
  }

  static Future<List<Pessoa>> getPessoas() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/pessoas'));
      print('GET /pessoas => ${response.statusCode}');
      if (response.statusCode == 200) {
        final List jsonList = json.decode(response.body);
        return jsonList.map((e) => Pessoa.fromJson(e)).toList();
      } else {
        throw Exception('Erro ao buscar pessoas');
      }
    } catch (e) {
      print('Erro no getPessoas: $e');
      rethrow;
    }
  }

  static Future<Pessoa?> getPessoaById(int id) async {
    try {
      final url = Uri.parse('$baseUrl/pessoas/$id');
      final response = await http.get(url);
      print('GET $url => ${response.statusCode}');
      print('Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return Pessoa.fromJson(jsonData);
      } else if (response.statusCode == 404) {
        print('Registro não encontrado (404)');
        return null;
      } else {
        throw Exception('Erro ao buscar pessoa: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro no getPessoaById: $e');
      rethrow;
    }
  }

  static Future<void> addPessoa(Pessoa pessoa) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/pessoas'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'nome': pessoa.nome,
          'email': pessoa.email,
          'telefone': pessoa.telefone,
        }),
      );
      print('POST /pessoas => ${response.statusCode}');
      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception('Erro ao adicionar pessoa');
      }
    } catch (e) {
      print('Erro no addPessoa: $e');
      rethrow;
    }
  }

  static Future<void> updatePessoa(Pessoa pessoa) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/pessoas/${pessoa.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'nome': pessoa.nome,
          'email': pessoa.email,
          'telefone': pessoa.telefone,
        }),
      );
      print('PUT /pessoas/${pessoa.id} => ${response.statusCode}');
      if (response.statusCode != 200) {
        throw Exception('Erro ao atualizar pessoa');
      }
    } catch (e) {
      print('Erro no updatePessoa: $e');
      rethrow;
    }
  }

  static Future<void> deletePessoa(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/pessoas/$id'));
      print('DELETE /pessoas/$id => ${response.statusCode}');
      if (response.statusCode != 200) {
        throw Exception('Erro ao excluir pessoa');
      }
    } catch (e) {
      print('Erro no deletePessoa: $e');
      rethrow;
    }
  }
}
