class Cadapr {
  final int apr_tr;
  final String apr_tipo;
  final String apr_situ;
  final DateTime apr_data;
  final int apr_tit;
  final String? tit_nome;
  final int apr_eqp;
  final String? eqp_desc;
  final double apr_htkm;
  final String apr_obs;
  final double apr_vltot;

  final List<Cadipr> itens;
  final List<Cadppr> parcelas;

  Cadapr({
    required this.apr_tr,
    required this.apr_tipo,
    required this.apr_situ,
    required this.apr_data,
    required this.apr_tit,
    this.tit_nome,
    required this.apr_eqp,
    this.eqp_desc,
    required this.apr_htkm,
    required this.apr_obs,
    required this.apr_vltot,
    required this.itens,
    required this.parcelas,
  });

  factory Cadapr.fromJson(Map<String, dynamic> json) {
    return Cadapr(
      apr_tr: json['apr_tr'],
      apr_tipo: json['apr_tipo'],
      apr_situ: json['apr_situ'],
      apr_data: DateTime.parse(json['apr_data']),
      apr_tit: json['apr_tit'],
      tit_nome: json['tit_nome'],
      apr_eqp: json['apr_eqp'],
      eqp_desc: json['eqp_desc'],
      apr_htkm: double.tryParse(json['apr_htkm'].toString()) ?? 0.0,
      apr_obs: json['apr_obs'],
      apr_vltot: double.tryParse(json['apr_vltot'].toString()) ?? 0.0,
      itens: json['itens'] != null
          ? (json['itens'] as List).map((e) => Cadipr.fromJson(e)).toList()
          : [],
      parcelas: json['parcelas'] != null
          ? (json['parcelas'] as List).map((e) => Cadppr.fromJson(e)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
    'apr_tr': apr_tr,
    'apr_tipo': apr_tipo,
    'apr_situ': apr_situ,
    'apr_data': apr_data.toIso8601String().split('T')[0],
    'apr_tit': apr_tit,
    'apr_eqp': apr_eqp,
    'apr_htkm': apr_htkm,
    'apr_obs': apr_obs,
    'apr_vltot': apr_vltot,
    'itens': itens.map((e) => e.toJson()).toList(),
    'parcelas': parcelas.map((e) => e.toJson()).toList(),
  };
}

//=========================================================================
// ITENS
class Cadipr {
  final int ipr_tr;
  final int ipr_it;
  final int ipr_his;
  final String? his_desc;
  final double ipr_qtd;
  final double ipr_vlunit;
  final double ipr_vltoti;

  Cadipr({
    required this.ipr_tr,
    required this.ipr_it,
    required this.ipr_his,
    this.his_desc,
    required this.ipr_qtd,
    required this.ipr_vlunit,
    required this.ipr_vltoti,
  });

  factory Cadipr.fromJson(Map<String, dynamic> json) {
    return Cadipr(
      ipr_tr: json['ipr_tr'],
      ipr_it: json['ipr_it'],
      ipr_his: json['ipr_his'],
      his_desc: json['his_desc'],
      ipr_qtd: double.tryParse(json['ipr_qtd'].toString()) ?? 0.0,
      ipr_vlunit: double.tryParse(json['ipr_vlunit'].toString()) ?? 0.0,
      ipr_vltoti: double.tryParse(json['ipr_vltoti'].toString()) ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'ipr_tr': ipr_tr,
    'ipr_it': ipr_it,
    'ipr_his': ipr_his,
    'ipr_qtd': ipr_qtd,
    'ipr_vlunit': ipr_vlunit,
    'ipr_vltoti': ipr_vltoti,
  };
}

//=========================================================================
// PARCELAS
class Cadppr {
  final int ppr_tr;
  final int ppr_pc;
  final DateTime ppr_dtv;
  final double ppr_vlpc;

  Cadppr({
    required this.ppr_tr,
    required this.ppr_pc,
    required this.ppr_dtv,
    required this.ppr_vlpc,
  });

  factory Cadppr.fromJson(Map<String, dynamic> json) {
    return Cadppr(
      ppr_tr: json['ppr_tr'],
      ppr_pc: json['ppr_pc'],
      ppr_dtv: DateTime.parse(json['ppr_dtv']),
      ppr_vlpc: double.tryParse(json['ppr_vlpc'].toString()) ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'ppr_tr': ppr_tr,
    'ppr_pc': ppr_pc,
    'ppr_dtv': ppr_dtv.toIso8601String().split('T')[0],
    'ppr_vlpc': ppr_vlpc,
  };
}
