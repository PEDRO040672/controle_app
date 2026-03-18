class Cadeqp {
  final int eqp_id;
  final String eqp_desc;
  final double eqp_htkm;

  Cadeqp({
    required this.eqp_id,
    required this.eqp_desc,
    required this.eqp_htkm,
  });

  factory Cadeqp.fromJson(Map<String, dynamic> json) {
    return Cadeqp(
      eqp_id: json['eqp_id'],
      eqp_desc: json['eqp_desc'],
      eqp_htkm: double.tryParse(json['eqp_htkm'].toString()) ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'eqp_id': eqp_id,
    'eqp_desc': eqp_desc,
    'eqp_htkm': eqp_htkm,
  };
}
