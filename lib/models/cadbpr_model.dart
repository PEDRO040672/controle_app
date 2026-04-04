class Cadbpr {
  final int bpr_tr;
  final int bpr_pc;
  final int bpr_it;
  final DateTime bpr_dtb;
  final String bpr_obs;
  final double bpr_vlb;

  Cadbpr({
    required this.bpr_tr,
    required this.bpr_pc,
    required this.bpr_it,
    required this.bpr_dtb,
    required this.bpr_obs,
    required this.bpr_vlb,
  });

  factory Cadbpr.fromJson(Map<String, dynamic> json) {
    return Cadbpr(
      bpr_tr: json['bpr_tr'],
      bpr_pc: json['bpr_pc'],
      bpr_it: json['bpr_it'],
      bpr_dtb: DateTime.parse(json['bpr_dtb']),
      bpr_obs: json['bpr_obs'],
      bpr_vlb: double.tryParse(json['bpr_vlb'].toString()) ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'bpr_tr': bpr_tr,
    'bpr_pc': bpr_pc,
    'bpr_it': bpr_it,
    'bpr_dtb': bpr_dtb.toIso8601String().split('T')[0],
    'bpr_obs': bpr_obs,
    'bpr_vlb': bpr_vlb,
  };
}
