import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/account_provider.dart';
import '../widgets/password_reset_dialog.dart';
import '../widgets/settings_section.dart';
import '../widgets/terms_dialog.dart';

const _faq = [
  (
    '¿Cómo inicio un trayecto?',
    'En Home elige o guarda un destino, asegúrate de tener un contacto '
        'principal y toca "INICIAR SAFEWALK".',
  ),
  (
    '¿Qué es el contacto de confianza principal?',
    'Es la persona que recibe primero los avisos si algo sale mal. En '
        'Contactos de confianza toca la estrella junto a su nombre.',
  ),
  (
    '¿Cómo agrego o edito contactos?',
    'Ve a Contactos de confianza y toca "Agregar". Para editar o eliminar '
        'usa el menú de tres puntos de cada contacto.',
  ),
  (
    '¿Dónde se guarda mi foto de perfil?',
    'Solo en tu teléfono. No se sube a ningún servidor; si cambias de '
        'dispositivo tendrás que elegirla otra vez.',
  ),
  (
    'No veo mis datos actualizados',
    'En Home o Contactos desliza hacia abajo para recargar la información '
        'desde Firebase.',
  ),
];

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  Future<void> _resetPassword(BuildContext context) async {
    final email = context.read<AccountProvider>().profile?.email ?? '';
    final sent = await showPasswordResetDialog(context, email);
    if (!sent || !context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Te enviamos un correo para cambiar tu contraseña.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ayuda y soporte',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
            children: [
              Card(
                color: colors.errorContainer,
                child: ListTile(
                  leading: Icon(
                    Icons.emergency_outlined,
                    color: colors.onErrorContainer,
                  ),
                  title: Text(
                    '¿Estás en peligro?',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: colors.onErrorContainer,
                    ),
                  ),
                  subtitle: Text(
                    'Llama al 911. SafeWalk no sustituye a los servicios de emergencia.',
                    style: TextStyle(color: colors.onErrorContainer),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SettingsSection(
                title: 'Preguntas frecuentes',
                children: [
                  for (final (question, answer) in _faq)
                    ExpansionTile(
                      title: Text(question),
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                          child: Text(
                            answer,
                            style: TextStyle(
                              height: 1.5,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              SettingsSection(
                title: 'Tu cuenta',
                children: [
                  ListTile(
                    leading: const Icon(Icons.lock_reset_rounded),
                    title: const Text('Cambiar contraseña'),
                    subtitle: const Text('Te enviamos un enlace a tu correo'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _resetPassword(context),
                  ),
                  const Divider(height: 1, indent: 20, endIndent: 20),
                  ListTile(
                    leading: const Icon(Icons.privacy_tip_outlined),
                    title: const Text('Términos y privacidad'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => showTermsDialog(context),
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
