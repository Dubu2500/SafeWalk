import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'auth_gate.dart';
import 'firebase_options.dart';
import 'models/app_settings.dart';
import 'screens/home_screen.dart';
import 'screens/map_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/register_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/trusted_contacts_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _settings = AppSettings();
  @override
  void dispose() {
    _settings.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SettingsScope(
    settings: _settings,
    child: AnimatedBuilder(
      animation: _settings,
      builder: (context, _) => MaterialApp(
        title: 'SafeWalk',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(Brightness.light),
        darkTheme: buildAppTheme(Brightness.dark),
        themeMode: _settings.darkMode ? ThemeMode.dark : ThemeMode.light,
        initialRoute: const String.fromEnvironment(
          'INITIAL_ROUTE',
          defaultValue: '/',
        ),
        routes: {
          '/': (_) => const AuthGate(),
          '/register': (_) => const RegisterScreen(),
          '/home': (_) => const HomeScreen(),
          '/map': (_) => const MapScreen(),
          '/settings': (_) => const SettingsScreen(),
          '/profile': (_) => const ProfileScreen(),
          '/contacts': (_) => const TrustedContactsScreen(),
        },
      ),
    ),
  );
}
