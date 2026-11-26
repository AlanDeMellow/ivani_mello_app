
import 'package:material_ui/material_ui.dart';

import 'api/api_service.dart';
import 'api/auth_service.dart';

import 'telas/login.dart';
import 'telas/home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Recupera o token salvo
  await AuthService.restaurarSessao();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ivani Mello Studio',
      debugShowCheckedModeBanner: false,

      localizationsDelegates:
          GlobalMaterialLocalizations.delegates,

      supportedLocales: const [
        Locale('pt', 'BR'),
        Locale('en', 'US'),
      ],

      locale: const Locale('pt', 'BR'),

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.pink,
        ),
        useMaterial3: true,
      ),

      // Verifica se existe uma sessão salva
      home: ApiService.token != null
          ? const HomePage()
          : const LoginPage(),
    );
  }
}
