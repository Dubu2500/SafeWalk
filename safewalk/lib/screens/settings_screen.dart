import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import '../providers/account_provider.dart';
import '../widgets/brand_mark.dart';
import '../widgets/settings_section.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  Future<void> _savePreference(
    BuildContext context,
    AccountProvider account,
    String key,
    bool value, {
    String? confirmation,
  }) async {
    try {
      await account.setPreference(key, value);
      if (confirmation != null && context.mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(confirmation)));
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo guardar la preferencia.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final account = context.watch<AccountProvider>();
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ajustes',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          tooltip: 'Volver a Home',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(context, '/home');
            }
          },
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
            children: [
              const Text(
                'A tu manera.',
                style: TextStyle(fontSize: 29, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                'Pequeños ajustes para sentirte más tranquilo en cada trayecto.',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 28),
              SettingsSection(
                title: 'Apariencia',
                children: [
                  SwitchListTile(
                    secondary: Icon(
                      account.darkMode
                          ? Icons.dark_mode_outlined
                          : Icons.light_mode_outlined,
                    ),
                    title: const Text('Modo oscuro'),
                    subtitle: const Text('Cambia la apariencia de toda la app'),
                    value: account.darkMode,
                    onChanged: (value) =>
                        _savePreference(context, account, 'darkMode', value),
                  ),
                ],
              ),
              SettingsSection(
                title: 'Tu acompañamiento',
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.notifications_none_rounded),
                    title: const Text('Notificaciones'),
                    subtitle: const Text(
                      'Preferencia de avisos de tus trayectos',
                    ),
                    value: account.notifications,
                    onChanged: (value) => _savePreference(
                      context,
                      account,
                      'notifications',
                      value,
                      confirmation: value
                          ? 'Notificaciones activadas.'
                          : 'Notificaciones desactivadas.',
                    ),
                  ),
                  const Divider(height: 1, indent: 20, endIndent: 20),
                  SwitchListTile(
                    secondary: const Icon(Icons.schedule_rounded),
                    title: const Text('Recordatorios'),
                    subtitle: const Text(
                      'Aviso cada 10 minutos con el trayecto abierto',
                    ),
                    value: account.journeyReminders,
                    onChanged: (value) => _savePreference(
                      context,
                      account,
                      'journeyReminders',
                      value,
                      confirmation: value
                          ? 'Recordatorios activados.'
                          : 'Recordatorios desactivados.',
                    ),
                  ),
                ],
              ),
              SettingsSection(
                title: 'Seguridad y privacidad',
                children: [
                  ListTile(
                    leading: const Icon(Icons.people_outline_rounded),
                    title: const Text('Contacto de confianza'),
                    subtitle: Text(
                      account.primaryContact?.name ??
                          'Elegir contacto principal',
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => Navigator.pushNamed(context, '/contacts'),
                  ),
                  const Divider(height: 1, indent: 20, endIndent: 20),
                  ExpansionTile(
                    leading: const Icon(Icons.location_on_outlined),
                    title: const Text('Ubicación durante el trayecto'),
                    subtitle: const Text('Tú decides cuándo compartir'),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        child: Text(
                          'SafeWalk usa tu ubicación solo durante un trayecto activo para mostrar tu ruta en el mapa. Tu ubicación solo se envía a tu contacto cuando tú lo eliges con "Compartir viaje" o "Necesito ayuda".',
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
                title: 'Acerca de',
                children: [
                  ListTile(
                    leading: const BrandMark(size: 40),
                    title: const Text('SafeWalk'),
                    subtitle: const Text(
                      'Tu tranquilidad, en cada paso. · v1.0',
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.help_outline_rounded),
                    title: const Text('Ayuda y soporte'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => Navigator.pushNamed(context, '/help'),
                  ),
                ],
              ),
              OutlinedButton.icon(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text('¿Cerrar sesión?'),
                    content: const Text(
                      'Volverás al inicio de sesión. Tendrás que ingresar de nuevo tu correo y contraseña.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text('Cancelar'),
                      ),
                      FilledButton(
                        onPressed: () async {
                          final userProvider = context.read<UserProvider>();
                          Navigator.pop(dialogContext);
                          await userProvider.signOut();
                          if (!context.mounted) return;
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/',
                            (route) => false,
                          );
                        },
                        child: const Text('Salir'),
                      ),
                    ],
                  ),
                ),
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Cerrar sesión'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Tus preferencias se guardan en tu cuenta de Firebase.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
