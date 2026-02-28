class Cadcid {
  final int cid_id;
  final String cid_nome;
  final String cid_uf;

  Cadcid({required this.cid_id, required this.cid_nome, required this.cid_uf});

  factory Cadcid.fromJson(Map<String, dynamic> json) {
    return Cadcid(
      cid_id: json['cid_id'],
      cid_nome: json['cid_nome'],
      cid_uf: json['cid_uf'],
    );
  }

  Map<String, dynamic> toJson() => {
    'cid_id': cid_id,
    'cid_nome': cid_nome,
    'cid_uf': cid_uf,
  };
}
