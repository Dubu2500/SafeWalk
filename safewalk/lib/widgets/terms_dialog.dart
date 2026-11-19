import 'package:flutter/material.dart';

const _sections = [
  (
    'Uso de SafeWalk',
    'SafeWalk te ayuda a avisar a tus contactos de confianza mientras haces un '
        'trayecto. No sustituye a los servicios de emergencia: si estás en peligro '
        'llama al 911.',
  ),
  (
    'Tu cuenta',
    'Eres responsable de mantener segura tu contraseña. Puedes editar tu nombre, '
        'teléfono y ciudad desde tu perfil en cualquier momento.',
  ),
  (
    'Datos que guardamos',
    'Guardamos en Firebase tu nombre, correo, teléfono, ciudad, preferencias, '
        'contactos de confianza y destinos. Tu foto de perfil se queda solo en tu '
        'teléfono y no se sube a ningún servidor.',
  ),
  (
    'Ubicación',
    'Tu ubicación solo se usa durante un trayecto activo y únicamente se comparte '
        'con los contactos que tú elijas.',
  ),
  (
    'Contactos de confianza',
    'Al agregar a alguien confirmas que esa persona está de acuerdo en recibir '
        'avisos de tus trayectos.',
  ),
  (
    'Eliminar tus datos',
    'Puedes borrar tus contactos y destinos desde la app. Para eliminar tu cuenta '
        'completa escríbenos desde Ajustes > Ayuda y soporte.',
  ),
];

Future<void> showTermsDialog(BuildContext context) => showDialog<void>(
  context: context,
  builder: (dialogContext) => AlertDialog(
    title: const Text('Términos y privacidad'),
    content: SizedBox(
      width: 420,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final (title, body) in _sections) ...[
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(body, style: const TextStyle(height: 1.4)),
              const SizedBox(height: 14),
            ],
          ],
        ),
      ),
    ),
    actions: [
      FilledButton(
        onPressed: () => Navigator.pop(dialogContext),
        child: const Text('Entendido'),
      ),
    ],
  ),
);
