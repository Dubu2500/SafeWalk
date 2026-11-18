import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/account_provider.dart';
import '../widgets/off_route.dart';
import '../widgets/pending_dialog.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final account = context.watch<AccountProvider>();
    final destination = account.selectedDestination;
    final contact = account.primaryContact;
    return Scaffold(
      appBar: AppBar(title: const Text('Tu trayecto')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            destination?.title ?? 'Sin destino seleccionado',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Text(destination?.subtitle ?? ''),
          const SizedBox(height: 24),
          Container(
            height: 240,
            alignment: Alignment.center,
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            child: const Text(
              'Mapa y seguimiento GPS pendientes de integrar.',
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text(contact?.name ?? 'Sin contacto principal'),
            subtitle: Text(
              contact?.phone ?? 'Selecciona un contacto en tu perfil.',
            ),
          ),
          FilledButton.icon(
            onPressed: contact == null
                ? null
                : () => showPendingDialog(
                    context,
                    'Compartir la ubicación en tiempo real está pendiente de integrar.',
                  ),
            icon: const Icon(Icons.share_location),
            label: const Text('Compartir viaje'),
          ),
          TextButton(
            onPressed: contact == null
                ? null
                : () => showPendingDialog(
                    context,
                    'El envío de ayuda a ${contact.name} está pendiente de integrar.',
                  ),
            child: const Text('Necesito ayuda'),
          ),
          OutlinedButton(
            onPressed: contact == null
                ? null
                : () => showOffRouteDialog(context, contact.name),
            child: const Text('Simular fuera de ruta'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Volver al inicio'),
          ),
        ],
      ),
    );
  }
}
