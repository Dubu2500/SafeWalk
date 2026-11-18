import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/account_provider.dart';
import '../widgets/destination_editor.dart';
import '../widgets/destination_card.dart';
import '../widgets/trusted_contact_card.dart';
import '../widgets/profile_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final account = context.watch<AccountProvider>();
    final name = account.displayName;
    final destinations = account.destinations;
    final query = _query.trim().toLowerCase();
    final visibleDestinations = destinations.where(
      (destination) => '${destination.title} ${destination.subtitle}'
          .toLowerCase()
          .contains(query),
    );

    return Scaffold(
      endDrawer: const ProfileDrawer(),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: RefreshIndicator(
              onRefresh: () async {
                try {
                  await account.refresh();
                } catch (_) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No se pudo actualizar.')),
                    );
                  }
                }
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hola, $name',
                                style: const TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
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
                        Builder(
                          builder: (context) => IconButton(
                            tooltip: 'Abrir menú de perfil',
                            onPressed: () =>
                                Scaffold.of(context).openEndDrawer(),
                            padding: EdgeInsets.zero,
                            icon: Container(
                              width: 50,
                              height: 50,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF2C408F),
                                    Color(0xFF4C7AE0),
                                  ],
                                ),
                              ),
                              child: Text(
                                name.substring(0, 1).toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
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
                        selected:
                            destination.id == account.selectedDestination?.id,
                        onTap: () {
                          FocusScope.of(context).unfocus();
                          account.selectDestination(destination.id);
                        },
                      ),
                      const SizedBox(height: 14),
                    ],
                    if (visibleDestinations.isEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 28),
                        child: Text(
                          destinations.isEmpty
                              ? 'Guarda tu primer destino para comenzar.'
                              : 'No se encontraron destinos.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    OutlinedButton.icon(
                      onPressed: () => showDialog<void>(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => const DestinationEditor(),
                      ),
                      icon: const Icon(Icons.add_location_alt_outlined),
                      label: const Text('Guardar destino'),
                    ),
                    const SizedBox(height: 16),
                    TrustedContactCard(
                      name:
                          account.primaryContact?.name ??
                          'Elegir contacto principal',
                      onTap: () => Navigator.pushNamed(context, '/contacts'),
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
                        onPressed:
                            account.selectedDestination == null ||
                                account.primaryContact == null
                            ? null
                            : () => Navigator.pushNamed(context, '/map'),
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
                      'Elige un destino y un contacto principal para iniciar.',
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
      ),
    );
  }
}
