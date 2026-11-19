import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth_gate.dart';
import 'firebase_options.dart';
import 'providers/user_provider.dart';
import 'providers/account_provider.dart';
import 'widgets/account_gate.dart';
import 'screens/home_screen.dart';
import 'screens/map_screen.dart';
import 'screens/pick_destination_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/register_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/trusted_contacts_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(
          create: (context) => AccountProvider(context.read<UserProvider>()),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    final account = context.watch<AccountProvider>();
    return MaterialApp(
      title: 'SafeWalk',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(Brightness.light),
      darkTheme: buildAppTheme(Brightness.dark),
      themeMode: account.darkMode ? ThemeMode.dark : ThemeMode.light,
      initialRoute: const String.fromEnvironment(
        'INITIAL_ROUTE',
        defaultValue: '/',
      ),
      routes: {
        '/': (_) => const AuthGate(),
        '/register': (_) => const RegisterScreen(),
        '/home': (_) => const AccountGate(child: HomeScreen()),
        '/map': (_) => const AccountGate(child: MapScreen()),
        '/pick-destination': (_) => const PickDestinationScreen(),
        '/settings': (_) => const AccountGate(child: SettingsScreen()),
        '/profile': (_) => const AccountGate(child: ProfileScreen()),
        '/contacts': (_) => const AccountGate(child: TrustedContactsScreen()),
      },
    );
  }
}
