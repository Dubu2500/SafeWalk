import 'package:flutter/material.dart';

import '../widgets/brand_mark.dart';
import '../widgets/pending_dialog.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const Align(alignment: Alignment.centerLeft, child: BrandMark()),
              const SizedBox(height: 20),
              const Text(
                'Qué bueno verte de nuevo',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text('Inicia sesión para empezar tu trayecto.'),
              const SizedBox(height: 30),
              const TextField(
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Correo electrónico',
                  prefixIcon: Icon(Icons.mail_outline),
                ),
              ),
              const SizedBox(height: 18),
              const TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  showPendingDialog(
                    context,
                    'Aquí se validarán tus datos. El inicio de sesión aún no está conectado; puedes explorar la demo.',
                    previewHome: true,
                  );
                },
                child: const Text('INICIAR SESIÓN'),
              ),
              const SizedBox(height: 12),
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text('¿No tienes cuenta?'),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    child: const Text('Crea una'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
