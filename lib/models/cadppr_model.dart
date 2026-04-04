class Cadppr {
  final int ppr_tr;
  final int ppr_pc;
  final DateTime ppr_vcto;
  final double ppr_vlpc;
  final String ppr_situ;

  Cadppr({
    required this.ppr_tr,
    required this.ppr_pc,
    required this.ppr_vcto,
    required this.ppr_vlpc,
    required this.ppr_situ,
  });

  factory Cadppr.fromJson(Map<String, dynamic> json) {
    return Cadppr(
      ppr_tr: json['ppr_tr'],
      ppr_pc: json['ppr_pc'],
      ppr_vcto: DateTime.parse(json['ppr_vcto']),
      ppr_vlpc: double.tryParse(json['ppr_vlpc'].toString()) ?? 0.0,
      ppr_situ: json['ppr_situ'],
    );
  }

  Map<String, dynamic> toJson() => {
    'ppr_tr': ppr_tr,
    'ppr_pc': ppr_pc,
    'ppr_vcto': ppr_vcto.toIso8601String().split('T')[0],
    'ppr_vlpc': ppr_vlpc,
    'ppr_situ': ppr_situ,
  };
}
