import 'package:material_ui/material_ui.dart';

import '../api/auth_service.dart';
import 'agendamentos.dart';
import 'login.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService authService = AuthService();

  bool saindo = false;

  // Encerra a sessão da administradora
  Future<void> _logout() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sair do aplicativo'),
        content: const Text(
          'Deseja realmente encerrar sua sessão?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, false);
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext, true);
            },
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;

    setState(() {
      saindo = true;
    });

    try {
      await authService.logout();

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        saindo = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao encerrar a sessão: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Ivani Mello Studio'),
        actions: [
          IconButton(
            onPressed: saindo ? null : _logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
          ),
        ],
      ),
      body: saindo
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    width: 190,
                    height: 190,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.image_not_supported_outlined,
                        size: 70,
                        color: Colors.grey,
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Bem-vindo ao Ivani Mello Studio!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'Gerenciamento de Agendamentos',
                  ),

                  const SizedBox(height: 25),

                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const AgendamentosPage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.calendar_month),
                    label: const Text('Ver agendamentos'),
                  ),
                ],
              ),
            ),
    );
  }
}
