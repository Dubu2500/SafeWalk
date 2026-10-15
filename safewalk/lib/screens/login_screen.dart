import 'package:flutter/material.dart';

import '../widgets/auth_field.dart';
import '../widgets/auth_layout.dart';
import '../widgets/pending_dialog.dart';
import '../widgets/primary_button.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  @override
  Widget build(BuildContext context) => AuthLayout(
    title: 'Qué bueno verte\nde nuevo.',
    subtitle: 'Inicia sesión para que te acompañemos en tu trayecto.',
    children: [
      const AuthField(
        label: 'Correo electrónico',
        hint: 'tu@correo.com',
        icon: Icons.mail_outline_rounded,
        keyboardType: TextInputType.emailAddress,
        autofillHints: [AutofillHints.email],
      ),
      const AuthField(
        label: 'Contraseña',
        hint: 'Tu contraseña',
        icon: Icons.lock_outline_rounded,
        password: true,
        autofillHints: [AutofillHints.password],
      ),
      Align(
        alignment: Alignment.centerRight,
        child: TextButton(
          onPressed: () => showPendingDialog(
            context,
            'La recuperación de contraseña estará disponible próximamente.',
          ),
          child: const Text('¿Olvidaste tu contraseña?'),
        ),
      ),
      const SizedBox(height: 12),
      PrimaryButton(
        label: 'INICIAR SESIÓN',
        onPressed: () => showPendingDialog(
          context,
          'Aquí se validarán tus datos. El inicio de sesión aún no está conectado; puedes explorar la demo.',
          previewHome: true,
        ),
      ),
      const SizedBox(height: 18),
      Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Text('¿No tienes cuenta?'),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/register'),
            child: const Text('Crea una'),
          ),
        ],
      ),
    ],
  );
}
