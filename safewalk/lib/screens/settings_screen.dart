import 'package:flutter/material.dart';

import '../models/app_settings.dart';
import '../widgets/brand_mark.dart';
import '../widgets/pending_dialog.dart';
import '../widgets/settings_section.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final settings = SettingsScope.of(context);
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
                      settings.darkMode
                          ? Icons.dark_mode_outlined
                          : Icons.light_mode_outlined,
                    ),
                    title: const Text('Modo oscuro'),
                    subtitle: const Text('Cambia la apariencia de toda la app'),
                    value: settings.darkMode,
                    onChanged: settings.setDarkMode,
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
                    value: settings.notifications,
                    onChanged: (value) {
                      settings.setNotifications(value);
                      showPendingDialog(
                        context,
                        'La preferencia cambia en esta sesión. Más adelante se enviarán notificaciones reales de tus trayectos. Funcionalidad pendiente.',
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 20, endIndent: 20),
                  SwitchListTile(
                    secondary: const Icon(Icons.schedule_rounded),
                    title: const Text('Recordatorios'),
                    subtitle: const Text('Recuerda avisar cuando llegues'),
                    value: settings.journeyReminders,
                    onChanged: (value) {
                      settings.setJourneyReminders(value);
                      showPendingDialog(
                        context,
                        'La preferencia cambia en esta sesión. Aquí se programarán recordatorios de llegada. Funcionalidad pendiente.',
                      );
                    },
                  ),
                ],
              ),
              SettingsSection(
                title: 'Seguridad y privacidad',
                children: [
                  ListTile(
                    leading: const Icon(Icons.people_outline_rounded),
                    title: const Text('Contacto de confianza'),
                    subtitle: const Text('María · Disponible'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => showPendingDialog(
                      context,
                      'Aquí podrás elegir y gestionar a las personas que te acompañarán durante tus trayectos. Funcionalidad pendiente.',
                    ),
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
                          'SafeWalk está diseñado para compartir tu ubicación solo durante un trayecto activo. Esta demo no accede al GPS ni comparte datos. La integración del mapa y seguimiento en tiempo real está pendiente.',
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
                    onTap: () => showPendingDialog(
                      context,
                      'Aquí podrás consultar ayuda y contactar al equipo de SafeWalk. Funcionalidad pendiente.',
                    ),
                  ),
                ],
              ),
              OutlinedButton.icon(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text('¿Salir de la demo?'),
                    content: const Text(
                      'Volverás al inicio de sesión. La autenticación y el cierre de sesión real están pendientes.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text('Cancelar'),
                      ),
                      FilledButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
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
                'Las preferencias se conservan mientras la app está abierta.',
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
