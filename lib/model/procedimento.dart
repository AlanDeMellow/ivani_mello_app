
class Procedimento {
  int? id;
  String nome;
  String? descricao;
  double preco;
  int duracao;

  Procedimento({
    this.id,
    required this.nome,
    this.descricao,
    required this.preco,
    required this.duracao,
  });

  // Converte os dados recebidos da API em um objeto Procedimento
  factory Procedimento.fromMap(Map<String, dynamic> json) {
    return Procedimento(
      id: json['id'],
      nome: json['nome'] ?? '',
      descricao: json['descricao'],
      preco: (json['preco'] as num).toDouble(),
      duracao: json['duracao'],
    );
  }

  // Converte o objeto Procedimento em Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'preco': preco,
      'duracao': duracao,
    };
  }
}
