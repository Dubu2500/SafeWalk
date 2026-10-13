import 'package:flutter/material.dart';

import '../data/home_data.dart';
import '../models/destination.dart';
import '../widgets/destination_card.dart';
import '../widgets/trusted_contact_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Destination _selectedDestination = destinations.first;
  String _query = '';

  void _showNotice(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final query = _query.trim().toLowerCase();
    final visibleDestinations = destinations.where(
      (destination) => '${destination.title} ${destination.subtitle}'
          .toLowerCase()
          .contains(query),
    );

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hola, $userName 👋',
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              '¿A dónde vas hoy?',
                              style: TextStyle(
                                fontSize: 17,
                                color: Color(0xFF848F9E),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 50,
                        height: 50,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Color(0xFF2C408F), Color(0xFF4C7AE0)],
                          ),
                        ),
                        child: const Text(
                          'R',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextField(
                      onChanged: (value) => setState(() => _query = value),
                      decoration: InputDecoration(
                        hintText: 'Buscar',
                        hintStyle: const TextStyle(
                          color: Color(0xFF959CA7),
                          fontSize: 17,
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: Color(0xFF9DA5B2),
                          size: 25,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 19,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(
                            color: Color(0xFFEEEEF2),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(
                            color: Color(0xFFEEEEF2),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  for (final destination in visibleDestinations) ...[
                    DestinationCard(
                      destination: destination,
                      selected: destination.id == _selectedDestination.id,
                      onTap: () {
                        FocusScope.of(context).unfocus();
                        if (destination.kind == DestinationKind.map) {
                          _showNotice(
                            'La selección en el mapa estará disponible próximamente.',
                          );
                          return;
                        }
                        setState(() => _selectedDestination = destination);
                      },
                    ),
                    const SizedBox(height: 14),
                  ],
                  if (visibleDestinations.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 28),
                      child: Text(
                        'No se encontraron destinos.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  const SizedBox(height: 16),
                  TrustedContactCard(
                    name: trustedContactName,
                    onTap: () => _showNotice(
                      'La gestión de contactos estará disponible próximamente.',
                    ),
                  ),
                  const SizedBox(height: 22),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(27),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF293B85), Color(0xFF345FE1)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF365DD8)
                              .withValues(alpha: 0.22),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () => _showNotice(
                        'Destino seleccionado: ${_selectedDestination.subtitle}. El inicio del trayecto estará disponible próximamente.',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 24,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(27),
                        ),
                      ),
                      child: const Text(
                        'INICIAR SAFEWALK',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Tu ubicación solo se comparte durante tu trayecto.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF9AA1AE),
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
