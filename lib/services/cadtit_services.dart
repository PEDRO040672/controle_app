import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cadtit_models.dart';
import '../core/api_config.dart';

class CadtitServices {
  Future<List<Cadtit>> getAll() async {
    final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/cadtit'));

    if (response.statusCode == 200) {
      final List jsonList = json.decode(response.body);
      return jsonList.map((e) => Cadtit.fromJson(e)).toList();
    } else {
      throw Exception('Erro ao buscar Titular.');
    }
  }

  Future<Cadtit?> getById(int tit_id) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/cadtit/$tit_id'),
    );
    if (response.statusCode == 200) {
      return Cadtit.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Erro ao buscar Titular.');
    }
  }

  Future<void> add(Cadtit cadtit) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/cadtit'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'tit_nome': cadtit.tit_nome,
        'tit_doc': cadtit.tit_doc,
        'tit_fone': cadtit.tit_fone,
        'tit_end': cadtit.tit_end,
        'tit_bai': cadtit.tit_bai,
        'tit_cep': cadtit.tit_cep,
        'tit_cid': cadtit.tit_cid,
        'tit_obs': cadtit.tit_obs,
      }),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Erro ao adicionar Titular.');
    }
  }

  Future<void> update(Cadtit cadtit) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/cadtit/${cadtit.tit_id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'tit_nome': cadtit.tit_nome,
        'tit_doc': cadtit.tit_doc,
        'tit_fone': cadtit.tit_fone,
        'tit_end': cadtit.tit_end,
        'tit_bai': cadtit.tit_bai,
        'tit_cep': cadtit.tit_cep,
        'tit_cid': cadtit.tit_cid,
        'tit_obs': cadtit.tit_obs,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao atualizar Titular.');
    }
  }

  Future<void> delete(int tit_id) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/cadtit/$tit_id'),
    );
    if (response.statusCode != 200) {
      throw Exception('Erro ao excluir Titular.');
    }
  }
}
