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
      body: json.encode({
        'os_tr': cados.os_tr,
        'os_os': cados.os_os,
        'os_situ': cados.os_situ,
        'os_data': cados.os_data,
        'os_hora': cados.os_hora,
        'os_his': cados.os_his,
        'os_cid': cados.os_cid,
        'os_tit': cados.os_tit,
        'os_eqp': cados.os_eqp,
        'os_ope': cados.os_ope,
        'os_obs': cados.os_obs,
        'os_htkmi': cados.os_htkmi,
        'os_htkmf': cados.os_htkmf,
        'os_qtd': cados.os_qtd,
        'os_vlunit': cados.os_vlunit,
        'os_vldesc': cados.os_vldesc,
        'os_vltots': cados.os_vltots,
      }),
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
      body: json.encode({
        'os_os': cados.os_os,
        'os_situ': cados.os_situ,
        'os_data': cados.os_data,
        'os_hora': cados.os_hora,
        'os_his': cados.os_his,
        'os_cid': cados.os_cid,
        'os_tit': cados.os_tit,
        'os_eqp': cados.os_eqp,
        'os_ope': cados.os_ope,
        'os_obs': cados.os_obs,
        'os_htkmi': cados.os_htkmi,
        'os_htkmf': cados.os_htkmf,
        'os_qtd': cados.os_qtd,
        'os_vlunit': cados.os_vlunit,
        'os_vldesc': cados.os_vldesc,
        'os_vltots': cados.os_vltots,
      }),
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
