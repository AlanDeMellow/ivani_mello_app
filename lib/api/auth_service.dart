
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService {
  final ApiService api = ApiService();

  static const String _tokenKey = 'access_token';

  // Realiza o login
  Future<Map<String, dynamic>> login(
    String email,
    String senha,
  ) async {
    final resposta = await api.post(
      '/auth/login',
      {
        'email': email,
        'password': senha,
      },
    );

    final token = resposta['access_token'];

    if (token == null || token.toString().isEmpty) {
      throw Exception('Token não recebido pelo servidor.');
    }

    if (resposta['role'] != 'ADMIN') {
      throw Exception(
        'Usuário sem permissão de administrador.',
      );
    }

    // Armazena o token em memória
    ApiService.token = token.toString();

    // Persiste o token no navegador
    final preferencias =
        await SharedPreferences.getInstance();

    await preferencias.setString(
      _tokenKey,
      token.toString(),
    );

    return resposta;
  }

  // Recupera o token salvo
  static Future<void> restaurarSessao() async {
    final preferencias =
        await SharedPreferences.getInstance();

    ApiService.token = preferencias.getString(_tokenKey);
  }

  // Encerra a sessão
  Future<void> logout() async {
    ApiService.token = null;

    final preferencias =
        await SharedPreferences.getInstance();

    await preferencias.remove(_tokenKey);
  }
}
