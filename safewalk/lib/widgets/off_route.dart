import 'package:flutter/material.dart';

Future<bool> showOffRouteDialog(
  BuildContext context,
  String contactName,
) async {
  final needsHelp = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => AlertDialog(
      icon: const Icon(Icons.warning_amber_rounded, color: Colors.orange),
      title: const Text('¿Todo está bien?'),
      content: Text(
        'Llevas unos minutos fuera de tu ruta. Responde en 00:20.\n\n'
        'Si no respondes, $contactName recibirá una alerta con tu última ubicación.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text(
            'Necesito ayuda',
            style: TextStyle(color: Colors.red),
          ),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Sí, estoy bien'),
        ),
      ],
    ),
  );
  return needsHelp ?? false;
}
