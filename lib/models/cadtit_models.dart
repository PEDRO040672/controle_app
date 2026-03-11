class Cadtit {
  final int tit_id;
  final String tit_nome;
  final String tit_doc;
  final String tit_fone;
  final String tit_end;
  final String tit_bai;
  final String tit_cep;
  final int tit_cid;
  final String tit_obs;

  Cadtit({
    required this.tit_id,
    required this.tit_nome,
    required this.tit_doc,
    required this.tit_fone,
    required this.tit_end,
    required this.tit_bai,
    required this.tit_cep,
    required this.tit_cid,
    required this.tit_obs,
  });

  factory Cadtit.fromJson(Map<String, dynamic> json) {
    return Cadtit(
      tit_id: json['tit_id'],
      tit_nome: json['tit_nome'],
      tit_doc: json['tit_doc'],
      tit_fone: json['tit_fone'],
      tit_end: json['tit_end'],
      tit_bai: json['tit_bai'],
      tit_cep: json['tit_cep'],
      tit_cid: json['tit_cid'],
      tit_obs: json['tit_obs'],
    );
  }

  Map<String, dynamic> toJson() => {
    'tit_id': tit_id,
    'tit_nome': tit_nome,
    'tit_doc': tit_doc,
    'tit_fone': tit_fone,
    'tit_end': tit_end,
    'tit_bai': tit_bai,
    'tit_cep': tit_cep,
    'tit_cid': tit_cid,
    'tit_obs': tit_obs,
  };
}
