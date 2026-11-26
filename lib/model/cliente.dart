
class Cliente {
  int? id;
  String nome;
  String telefone;
  String? email;
  String? observacoes;

  Cliente({
    this.id,
    required this.nome,
    required this.telefone,
    this.email,
    this.observacoes,
  });

  // Converte os dados recebidos da API em um objeto Cliente
  factory Cliente.fromMap(Map<String, dynamic> json) {
    return Cliente(
      id: json['id'],
      nome: json['nome'] ?? '',
      telefone: json['telefone'] ?? '',
      email: json['email'],
      observacoes: json['observacoes'],
    );
  }

  // Converte o objeto Cliente em Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'telefone': telefone,
      'email': email,
      'observacoes': observacoes,
    };
  }
}
