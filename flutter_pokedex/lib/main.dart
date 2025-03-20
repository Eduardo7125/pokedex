import 'package:flutter/material.dart';
import 'package:flutter_pokedex/Models/PokemonAdapter.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/PokemonList.dart';
import 'providers/pokemon_provider.dart';
import 'core/notification_service.dart';
import 'core/hive_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(PokemonAdapter());
  await HiveHelper.init();
  await NotificationService.instance.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PokemonProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Pokédex',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.light(
            primary: Colors.red.shade700,
            secondary: Colors.red.shade500,
          ),
          cardTheme: CardTheme(
            color: Colors.grey.shade50,
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.dark(
            primary: Colors.red.shade200,
            secondary: Colors.red.shade300,
            surface: Colors.grey.shade900,
          ),
          cardTheme: CardTheme(
            color: Colors.grey.shade900,
          ),
        ),
        themeMode: _themeMode,
        home: PokemonList(
          onThemeToggle: toggleTheme,
        ),
      ),
    );
  }
}
