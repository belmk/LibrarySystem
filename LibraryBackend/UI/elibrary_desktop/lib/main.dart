import 'package:elibrary_desktop/providers/auth_provider.dart';
import 'package:elibrary_desktop/providers/base_provider.dart';
import 'package:elibrary_desktop/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  final String? apiBaseUrlFromEnv = dotenv.env['API_URL'];

  if (apiBaseUrlFromEnv != null && apiBaseUrlFromEnv.isNotEmpty) {
    BaseProvider.baseUrl = apiBaseUrlFromEnv;
    print('API Base URL loaded from .env: ${BaseProvider.baseUrl}');
  } else {
    BaseProvider.baseUrl = "http://localhost:7012/";
    print(
      'Warning: API_BASE_URL not found in .env. Using default: ${BaseProvider.baseUrl}',
    );
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthProvider())],
      child: MaterialApp(
        title: 'Admin Panel',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: LoginScreen(),
      ),
    );
  }
}
