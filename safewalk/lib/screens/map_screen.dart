import 'package:flutter/material.dart';

import '../data/home_data.dart';
import '../widgets/friend_card.dart';
import '../widgets/off_route.dart';
import '../widgets/pending_dialog.dart';
import '../widgets/trip_header.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const TripHeader(),

              // Aquí irá el mapa
              Container(
                height: 320,
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
                child: Stack(
                  children: [
                    const Positioned(
                      left: 16,
                      bottom: 16,
                      child: Chip(label: Text('1.8 km · 18 min')),
                    ),
                    Positioned(
                      left: 16,
                      right: 16,
                      top: 16,
                      child: Align(
                        alignment: Alignment.topRight,
                        child: ActionChip(
                          label: const Text('Simular fuera de ruta'),
                          onPressed: () {
                            showOffRouteDialog(context, trustedContactName);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const CompanionCard(name: trustedContactName),
                    const SizedBox(height: 14),
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.red.shade50,
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                      ),
                      onPressed: () {
                        showPendingDialog(
                          context,
                          'El aviso de ayuda a $trustedContactName estará disponible próximamente.',
                        );
                      },
                      child: const Text('Necesito ayuda'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Finalizar SafeWalk'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
