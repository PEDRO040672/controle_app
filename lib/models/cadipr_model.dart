class Cadipr {
  final int ipr_tr;
  final int ipr_it;
  final String ipr_desc;
  final double ipr_qtd;
  final double ipr_vlunit;
  final double ipr_vltot;

  Cadipr({
    required this.ipr_tr,
    required this.ipr_it,
    required this.ipr_desc,
    required this.ipr_qtd,
    required this.ipr_vlunit,
    required this.ipr_vltot,
  });

  factory Cadipr.fromJson(Map<String, dynamic> json) {
    return Cadipr(
      ipr_tr: json['ipr_tr'],
      ipr_it: json['ipr_it'],
      ipr_desc: json['ipr_desc'],
      ipr_qtd: double.tryParse(json['ipr_qtd'].toString()) ?? 0.0,
      ipr_vlunit: double.tryParse(json['ipr_vlunit'].toString()) ?? 0.0,
      ipr_vltot: double.tryParse(json['ipr_vltot'].toString()) ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'ipr_tr': ipr_tr,
    'ipr_it': ipr_it,
    'ipr_desc': ipr_desc,
    'ipr_qtd': ipr_qtd,
    'ipr_vlunit': ipr_vlunit,
    'ipr_vltot': ipr_vltot,
  };
}
