import 'package:flutter/material.dart';

import '../widgets/auth_field.dart';
import '../widgets/auth_layout.dart';
import '../widgets/pending_dialog.dart';
import '../widgets/primary_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _accepted = false;
  @override
  Widget build(BuildContext context) => AuthLayout(
    back: true,
    title: 'Tu camino seguro\nempieza aquí.',
    subtitle:
        'Crea tu cuenta y comparte tus trayectos con quienes más te cuidan.',
    children: [
      const AuthField(
        label: 'Nombre completo',
        hint: '¿Cómo te llamas?',
        icon: Icons.person_outline_rounded,
        autofillHints: [AutofillHints.name],
      ),
      const AuthField(
        label: 'Correo electrónico',
        hint: 'tu@correo.com',
        icon: Icons.mail_outline_rounded,
        keyboardType: TextInputType.emailAddress,
        autofillHints: [AutofillHints.email],
      ),
      const AuthField(
        label: 'Contraseña',
        hint: 'Crea una contraseña',
        icon: Icons.lock_outline_rounded,
        password: true,
        autofillHints: [AutofillHints.newPassword],
      ),
      const AuthField(
        label: 'Confirmar contraseña',
        hint: 'Repite tu contraseña',
        icon: Icons.lock_outline_rounded,
        password: true,
      ),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: _accepted,
            onChanged: (value) => setState(() => _accepted = value ?? false),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text(
                    'He leído y acepto los',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    alignment: Alignment.centerLeft,
                  ),
                  onPressed: () => showPendingDialog(
                    context,
                    'Aquí se mostrarán los términos de uso y el aviso de privacidad de SafeWalk. El contenido legal está pendiente.',
                  ),
                  child: const Text('Términos y privacidad'),
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      PrimaryButton(
        label: 'CREAR CUENTA',
        onPressed: () => showPendingDialog(
          context,
          'Aquí se validarán tus datos y se creará tu cuenta. El registro aún no guarda información; puedes explorar la demo.',
          previewHome: true,
        ),
      ),
      const SizedBox(height: 18),
      Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Text('¿Ya tienes una cuenta?'),
          TextButton(
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                Navigator.pushReplacementNamed(context, '/');
              }
            },
            child: const Text('Inicia sesión'),
          ),
        ],
      ),
    ],
  );
}
