import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafeWalk',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF365DD8)),
        scaffoldBackgroundColor: const Color(0xFFF5F6FB),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Color(0xFF172029)),
        ),
      ),
      // Preview: flutter run --dart-define=INITIAL_ROUTE=/home
      initialRoute: const String.fromEnvironment(
        'INITIAL_ROUTE',
        defaultValue: '/',
      ),
      routes: {
        '/': (_) => const Scaffold(body: Center(child: Text('Login'))),
        '/home': (_) => const HomeScreen(),
      },
    );
  }
}
