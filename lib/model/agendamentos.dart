class Agendamento {
  int? id;

  // IDs utilizados pela API
  int? clienteId;
  int? procedimentoId;

  // Nomes para apresentação na tela
  String? cliente;
  String? procedimento;

  DateTime? dataHora;
  String? status;
  String? observacoes;

  Agendamento() {
    id = null;
    clienteId = null;
    procedimentoId = null;
    cliente = '';
    procedimento = '';
    dataHora = DateTime.now();
    status = 'Agendado';
    observacoes = '';
  }

  // Mantém o construtor utilizado na tela atual
  Agendamento.init(
    this.id,
    this.cliente,
    this.procedimento,
    this.dataHora,
    this.status,
    this.observacoes,
  );

  // Converte os dados da API em objeto Agendamento
  factory Agendamento.fromMap(Map<String, dynamic> json) {
    final clienteJson = json['cliente'];
    final procedimentoJson = json['procedimento'];

    return Agendamento()
      ..id = json['id']
      ..clienteId = json['clienteId']
      ..procedimentoId = json['procedimentoId']
      ..cliente = clienteJson is Map
          ? clienteJson['nome']?.toString()
          : ''
      ..procedimento = procedimentoJson is Map
          ? procedimentoJson['nome']?.toString()
          : ''
      ..dataHora = DateTime.parse(json['dataHora'].toString())
      ..status = json['status']?.toString() ?? 'Agendado'
      ..observacoes = json['observacoes']?.toString() ?? '';
  }

  // Converte o objeto em Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'clienteId': clienteId,
      'procedimentoId': procedimentoId,
      'dataHora': dataHora?.toIso8601String(),
      'status': status,
      'observacoes': observacoes,
    };
  }
}
