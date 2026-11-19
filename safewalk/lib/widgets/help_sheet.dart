import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/trusted_contact.dart';
import '../services/trip_service.dart';

String helpMessage(LatLng? location) {
  final where = location == null
      ? ''
      : ' Esta es mi ubicación: ${TripService.mapLink(location)}';
  return 'Necesito ayuda, estoy en un trayecto con SafeWalk.$where';
}

Future<bool> sendSms(String phone, String message) => launchUrl(
  Uri(
    scheme: 'sms',
    path: phone.replaceAll(' ', ''),
    query: 'body=${Uri.encodeComponent(message)}',
  ),
);

Future<bool> call(String phone) =>
    launchUrl(Uri(scheme: 'tel', path: phone.replaceAll(' ', '')));

Future<void> showHelpSheet(
  BuildContext context, {
  required TrustedContact? contact,
  required LatLng? location,
}) {
  final messenger = ScaffoldMessenger.of(context);
  Future<void> run(Future<bool> Function() action) async {
    try {
      if (await action()) return;
    } catch (_) {}
    messenger.showSnackBar(
      const SnackBar(content: Text('No se pudo abrir la app del teléfono.')),
    );
  }

  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (contact != null) ...[
            ListTile(
              leading: const Icon(Icons.sms_outlined),
              title: Text('Enviar mensaje a ${contact.name}'),
              subtitle: const Text('Con tu ubicación actual'),
              onTap: () {
                Navigator.pop(sheetContext);
                run(() => sendSms(contact.phone, helpMessage(location)));
              },
            ),
            ListTile(
              leading: const Icon(Icons.call_outlined),
              title: Text('Llamar a ${contact.name}'),
              subtitle: Text(contact.phone),
              onTap: () {
                Navigator.pop(sheetContext);
                run(() => call(contact.phone));
              },
            ),
          ],
          ListTile(
            leading: const Icon(Icons.emergency_outlined, color: Colors.red),
            title: const Text(
              'Llamar al 911',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              Navigator.pop(sheetContext);
              run(() => call('911'));
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}
