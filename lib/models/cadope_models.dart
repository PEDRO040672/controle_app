class Cadope {
  final int ope_id;
  final String ope_nome;
  final double ope_fixo;
  final double ope_perc;

  Cadope({
    required this.ope_id,
    required this.ope_nome,
    required this.ope_fixo,
    required this.ope_perc,
  });

  factory Cadope.fromJson(Map<String, dynamic> json) {
    return Cadope(
      ope_id: json['ope_id'],
      ope_nome: json['ope_nome'],
      ope_fixo: double.tryParse(json['ope_fixo'].toString()) ?? 0.00,
      ope_perc: double.tryParse(json['ope_perc'].toString()) ?? 0.00,
    );
  }

  Map<String, dynamic> toJson() => {
    'ope_id': ope_id,
    'ope_nome': ope_nome,
    'ope_fixo': ope_fixo,
    'ope_perc': ope_perc,
  };
}
