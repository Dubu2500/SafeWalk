import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth_gate.dart';
import 'firebase_options.dart';
import 'providers/user_provider.dart';
import 'providers/account_provider.dart';
import 'providers/device_token_provider.dart';
import 'providers/photo_provider.dart';
import 'widgets/account_gate.dart';
import 'screens/help_screen.dart';
import 'screens/home_screen.dart';
import 'screens/map_screen.dart';
import 'screens/pick_destination_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/register_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/trusted_contacts_screen.dart';
import 'theme/app_theme.dart';

final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('Title del mensaje: ${message.notification?.title}');
  debugPrint('Body del mensaje: ${message.notification?.body}');
  debugPrint('ID del mensaje: ${message.messageId}');
}

Future<void> _setUpNotifications() async {
  try {
    await FirebaseMessaging.instance.requestPermission();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  } catch (error) {
    debugPrint('Notificaciones no disponibles: $error');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await _setUpNotifications();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(
          create: (context) => AccountProvider(context.read<UserProvider>()),
        ),
        ChangeNotifierProvider(
          create: (context) => PhotoProvider(context.read<UserProvider>()),
        ),
        ChangeNotifierProvider(
          lazy: false,
          create: (context) => DeviceTokenProvider(
            context.read<AccountProvider>(),
            onForegroundMessage: (title, body) =>
                scaffoldMessengerKey.currentState?.showSnackBar(
                  SnackBar(
                    content: Text(title.isEmpty ? body : '$title\n$body'),
                  ),
                ),
          ),
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
      scaffoldMessengerKey: scaffoldMessengerKey,
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
        '/help': (_) => const AccountGate(child: HelpScreen()),
      },
    );
  }
}
