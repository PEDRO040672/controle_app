class Pessoa {
  final int id;
  final String nome;
  final String email;
  final String telefone;

  Pessoa({
    required this.id,
    required this.nome,
    required this.email,
    required this.telefone,
  });

  factory Pessoa.fromJson(Map<String, dynamic> json) {
    return Pessoa(
      id: json['id'],
      nome: json['nome'],
      email: json['email'],
      telefone: json['telefone'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nome': nome,
    'email': email,
    'telefone': telefone,
  };
}
