import 'dart:convert';

import 'package:http/http.dart' as http;

import '../model/cliente.dart';
import '../model/procedimento.dart';
import '../model/agendamentos.dart';

class ApiService {
  // Endereço do backend
  static const String baseUrl = 'http://localhost:3000/api';

  // Token de autenticação
  static String? token;

  // Cabeçalhos das requisições
  Map<String, String> _headers() {
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // GET
  Future<dynamic> get(String endpoint) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers(),
    );

    return _tratarResposta(response);
  }

  // POST
  Future<dynamic> post(String endpoint, Map<String, dynamic> dados) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers(),
      body: jsonEncode(dados),
    );

    return _tratarResposta(response);
  }

  // PATCH
  Future<dynamic> patch(String endpoint, Map<String, dynamic> dados) async {
    final response = await http.patch(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers(),
      body: jsonEncode(dados),
    );

    return _tratarResposta(response);
  }

  // DELETE
  Future<dynamic> delete(String endpoint) async {
    final response = await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers(),
    );

    return _tratarResposta(response);
  }

  // Busca os clientes cadastrados
  Future<List<Cliente>> buscarClientes() async {
    final resposta = await get('/clientes');

    return (resposta as List).map((item) {
      return Cliente.fromMap(Map<String, dynamic>.from(item));
    }).toList();
  }

  // Busca os procedimentos cadastrados
  Future<List<Procedimento>> buscarProcedimentos() async {
    final resposta = await get('/procedimentos');

    return (resposta as List).map((item) {
      return Procedimento.fromMap(Map<String, dynamic>.from(item));
    }).toList();
  }

  // Tratamento das respostas da API
  dynamic _tratarResposta(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return null;
      }

      return jsonDecode(response.body);
    }

    throw Exception('Erro ${response.statusCode}: ${response.body}');
  }

  // Busca os agendamentos cadastrados
  Future<List<Agendamento>> buscarAgendamentos() async {
    final resposta = await get('/agendamentos');

    return (resposta as List).map((item) {
      return Agendamento.fromMap(Map<String, dynamic>.from(item));
    }).toList();
  }
}
