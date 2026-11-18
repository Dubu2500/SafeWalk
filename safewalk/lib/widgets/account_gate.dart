import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/account_provider.dart';
import '../providers/user_provider.dart';
import '../screens/login_screen.dart';

class AccountGate extends StatelessWidget {
  const AccountGate({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    if (!context.watch<UserProvider>().isLoggedIn) return const LoginScreen();
    final account = context.watch<AccountProvider>();
    if (account.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (account.error != null || account.profile == null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(account.error ?? 'No se encontró tu perfil.'),
                FilledButton(
                  onPressed: account.retry,
                  child: const Text('Reintentar'),
                ),
                TextButton(
                  onPressed: () => context.read<UserProvider>().signOut(),
                  child: const Text('Cerrar sesión'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return child;
  }
}
