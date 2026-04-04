class Cadapr {
  final int apr_tr;
  final String apr_tipo;
  final DateTime apr_data;
  final int apr_tit;
  final String tit_nome;
  final int apr_eqp;
  final String eqp_desc;
  final String apr_obs;
  final double apr_htkm;
  final double apr_vltot;
  final String apr_situ;

  Cadapr({
    required this.apr_tr,
    required this.apr_tipo,
    required this.apr_data,
    required this.apr_tit,
    required this.tit_nome,
    required this.apr_eqp,
    required this.eqp_desc,
    required this.apr_obs,
    required this.apr_htkm,
    required this.apr_vltot,
    required this.apr_situ,
  });

  factory Cadapr.fromJson(Map<String, dynamic> json) {
    return Cadapr(
      apr_tr: json['apr_tr'],
      apr_tipo: json['apr_tipo'],
      apr_data: DateTime.parse(json['apr_data']),
      apr_tit: json['apr_tit'],
      tit_nome: json['tit_nome'],
      apr_eqp: json['apr_eqp'],
      eqp_desc: json['eqp_desc'],
      apr_obs: json['apr_obs'],
      apr_htkm: double.tryParse(json['apr_htkm'].toString()) ?? 0.0,
      apr_vltot: double.tryParse(json['apr_vltot'].toString()) ?? 0.0,
      apr_situ: json['apr_situ'],
    );
  }

  Map<String, dynamic> toJson() => {
    'apr_tr': apr_tr,
    'apr_tipo': apr_tipo,
    'apr_data': apr_data.toIso8601String().split('T')[0],
    'apr_tit': apr_tit,
    'tit_nome': tit_nome,
    'apr_eqp': apr_eqp,
    'eqp_desc': eqp_desc,
    'apr_obs': apr_obs,
    'apr_htkm': apr_htkm,
    'apr_vltot': apr_vltot,
    'apr_situ': apr_situ,
  };
}
