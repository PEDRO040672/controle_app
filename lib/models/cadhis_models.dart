class Cadhis {
  final int his_id;
  final String his_desc;
  final String his_cc;
  final double his_intervalo;

  Cadhis({
    required this.his_id,
    required this.his_desc,
    required this.his_cc,
    required this.his_intervalo,
  });

  factory Cadhis.fromJson(Map<String, dynamic> json) {
    return Cadhis(
      his_id: json['his_id'],
      his_desc: json['his_desc'],
      his_cc: json['his_cc'],
      his_intervalo: double.tryParse(json['his_intervalo'].toString()) ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'his_id': his_id,
    'his_desc': his_desc,
    'his_cc': his_cc,
    'his_intervalo': his_intervalo,
  };
}
