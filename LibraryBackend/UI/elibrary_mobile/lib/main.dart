import 'package:elibrary_mobile/providers/book_provider.dart';
import 'package:elibrary_mobile/providers/genre_provider.dart';
import 'package:elibrary_mobile/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/base_provider.dart';
import 'screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print('Loading .env ...');
  await dotenv.load(fileName: ".env");
  print('Loading finished!');

  final apiUrl = dotenv.env['API_URL'];
  if (apiUrl != null && apiUrl.isNotEmpty) {
    BaseProvider.baseUrl = apiUrl;
    print('API Base URL loaded from .env: $apiUrl');
  } else {
    BaseProvider.baseUrl = "http://10.0.2.2:7012/";
    print('Warning: API_URL not found in .env. Using default: ${BaseProvider.baseUrl}');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => BookProvider()),
        ChangeNotifierProvider(create: (_) => GenreProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'eLibrary Mobile',
        theme: ThemeData(
          colorSchemeSeed: Colors.blue,
          useMaterial3: true,
        ),
        home: const LoginScreen(),
      ),
    );
  }
}
