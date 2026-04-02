class Cados {
  final int os_tr;
  final int os_os;
  final String os_situ;
  final DateTime os_data;
  final String os_hora;
  final int os_his;
  final String his_desc;
  final int os_cid;
  final String cid_nome;
  final int os_tit;
  final String tit_nome;
  final int os_eqp;
  final String eqp_desc;
  final int os_ope;
  final String ope_nome;
  final String os_obs;
  final double os_htkmi;
  final double os_htkmf;
  final double os_qtd;
  final double os_vlunit;
  final double os_vldesc;
  final double os_vltots;

  Cados({
    required this.os_tr,
    required this.os_os,
    required this.os_situ,
    required this.os_data,
    required this.os_hora,
    required this.os_his,
    required this.his_desc,
    required this.os_cid,
    required this.cid_nome,
    required this.os_tit,
    required this.tit_nome,
    required this.os_eqp,
    required this.eqp_desc,
    required this.os_ope,
    required this.ope_nome,
    required this.os_obs,
    required this.os_htkmi,
    required this.os_htkmf,
    required this.os_qtd,
    required this.os_vlunit,
    required this.os_vldesc,
    required this.os_vltots,
  });

  factory Cados.fromJson(Map<String, dynamic> json) {
    return Cados(
      os_tr: json['os_tr'],
      os_os: json['os_os'],
      os_situ: json['os_situ'],
      os_data: DateTime.parse(json['os_data']),
      os_hora: json['os_hora'],
      os_his: json['os_his'],
      his_desc: json['his_desc'],
      os_cid: json['os_cid'],
      cid_nome: json['cid_nome'],
      os_tit: json['os_tit'],
      tit_nome: json['tit_nome'],
      os_eqp: json['os_eqp'],
      eqp_desc: json['eqp_desc'],
      os_ope: json['os_ope'],
      ope_nome: json['ope_nome'],
      os_obs: json['os_obs'],
      os_htkmi: double.tryParse(json['os_htkmi'].toString()) ?? 0.0,
      os_htkmf: double.tryParse(json['os_htkmf'].toString()) ?? 0.0,
      os_qtd: double.tryParse(json['os_qtd'].toString()) ?? 0.0,
      os_vlunit: double.tryParse(json['os_vlunit'].toString()) ?? 0.00,
      os_vldesc: double.tryParse(json['os_vldesc'].toString()) ?? 0.00,
      os_vltots: double.tryParse(json['os_vltots'].toString()) ?? 0.00,
    );
  }

  Map<String, dynamic> toJson() => {
    'os_tr': os_tr,
    'os_os': os_os,
    'os_situ': os_situ,
    'os_data': os_data.toIso8601String().split('T')[0],
    'os_hora': os_hora,
    'os_his': os_his,
    'his_desc': his_desc,
    'os_cid': os_cid,
    'cid_nome': cid_nome,
    'os_tit': os_tit,
    'tit_nome': tit_nome,
    'os_eqp': os_eqp,
    'eqp_desc': eqp_desc,
    'os_ope': os_ope,
    'ope_nome': ope_nome,
    'os_obs': os_obs,
    'os_htkmi': os_htkmi,
    'os_htkmf': os_htkmf,
    'os_qtd': os_qtd,
    'os_vlunit': os_vlunit,
    'os_vldesc': os_vldesc,
    'os_vltots': os_vltots,
  };
}
