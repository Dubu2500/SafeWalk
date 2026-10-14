import 'package:flutter/material.dart';

Future<void> showPendingDialog(
  BuildContext context,
  String message, {
  bool previewHome = false,
}) => showDialog<void>(
  context: context,
  builder: (dialogContext) => AlertDialog(
    icon: const Icon(Icons.info_outline_rounded),
    title: const Text('Funcionalidad pendiente'),
    content: Text(message),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(dialogContext),
        child: const Text('Entendido'),
      ),
      if (previewHome)
        FilledButton(
          onPressed: () {
            Navigator.pop(dialogContext);
            Navigator.of(context)
                .pushNamedAndRemoveUntil('/home', (route) => false);
          },
          child: const Text('Explorar demo'),
        ),
    ],
  ),
);
