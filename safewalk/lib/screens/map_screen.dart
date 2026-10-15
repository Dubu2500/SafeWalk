import 'package:flutter/material.dart';

import '../data/home_data.dart';
import '../widgets/pending_dialog.dart';

const _green = Color(0xFF3FA55A);
const _orange = Color(0xFFE8A33D);
const _red = Color(0xFFD64545);

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  bool _offRoute = false;

  Future<void> _simulateOffRoute() async {
    setState(() => _offRoute = true);
    await showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _OffRouteSheet(),
    );
    if (mounted) setState(() => _offRoute = false);
  }

  void _askForHelp() => showPendingDialog(
    context,
    'El aviso de ayuda a $trustedContactName estará disponible próximamente.',
  );

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _StatusHeader(offRoute: _offRoute),
                    SizedBox(
                      height: (constraints.maxHeight * 0.45).clamp(
                        240.0,
                        460.0,
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: ColoredBox(
                              color: scheme.surfaceContainerHigh,
                            ),
                          ),
                          Positioned(
                            left: 16,
                            bottom: 16,
                            child: _MapChip(
                              icon: Icons.schedule_rounded,
                              label: '1.8 km · 18 min',
                              color: scheme.primary,
                            ),
                          ),
                          Positioned(
                            left: 16,
                            right: 16,
                            top: 16,
                            child: Align(
                              alignment: Alignment.topRight,
                              child: ActionChip(
                                avatar: const Icon(
                                  Icons.alt_route_rounded,
                                  size: 18,
                                ),
                                label: const Text('Simular fuera de ruta'),
                                onPressed: _simulateOffRoute,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const _CompanionCard(),
                          const SizedBox(height: 14),
                          _SoftButton(
                            label: 'Necesito ayuda',
                            icon: Icons.notifications_active_rounded,
                            color: _red,
                            onPressed: _askForHelp,
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton(
                            onPressed: () => Navigator.maybePop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22),
                              ),
                              side: BorderSide(color: scheme.outlineVariant),
                            ),
                            child: const Text(
                              'Finalizar SafeWalk',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
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

class _StatusHeader extends StatelessWidget {
  const _StatusHeader({required this.offRoute});
  final bool offRoute;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = offRoute ? _orange : _green;
    return Container(
      color: scheme.surface,
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.paddingOf(context).top + 14,
        20,
        16,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.circle, size: 11, color: color),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'SafeWalk activo',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  offRoute ? 'Fuera de ruta' : 'Todo está bien',
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Llegarás aprox.',
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
                const SizedBox(height: 2),
                const Text(
                  '11:04 PM',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MapChip extends StatelessWidget {
  const _MapChip({
    required this.icon,
    required this.label,
    required this.color,
  });
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    ),
  );
}

class _CompanionCard extends StatelessWidget {
  const _CompanionCard();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: scheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF8040E9), Color(0xFFA477EF)],
                  ),
                ),
                child: Text(
                  trustedContactName.substring(0, 1),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 13,
                  height: 13,
                  decoration: BoxDecoration(
                    color: const Color(0xFF59C36A),
                    shape: BoxShape.circle,
                    border: Border.all(color: scheme.surface, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$trustedContactName está acompañándote',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Recibirá una alerta si detectamos algo inusual.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const SizedBox(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(
              value: 0.75,
              strokeWidth: 4,
              color: Color(0xFF59C36A),
              backgroundColor: Color(0x3359C36A),
            ),
          ),
        ],
      ),
    );
  }
}

class _SoftButton extends StatelessWidget {
  const _SoftButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => TextButton.icon(
    onPressed: onPressed,
    icon: Icon(icon, color: color),
    label: Text(
      label,
      style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w800),
    ),
    style: TextButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 20),
      backgroundColor: color.withValues(alpha: 0.10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: color.withValues(alpha: 0.30)),
      ),
    ),
  );
}

class _OffRouteSheet extends StatelessWidget {
  const _OffRouteSheet();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _orange.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: _orange.withValues(alpha: 0.4),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.circle, size: 9, color: _orange),
                              SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  'Fuera de ruta',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: _orange,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.schedule_rounded, color: _red, size: 20),
                      const SizedBox(width: 4),
                      const Text(
                        '00:20',
                        style: TextStyle(
                          color: _red,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    '¿Todo está bien?',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Llevas unos minutos fuera de tu ruta. Responde en 00:20.',
                    style: TextStyle(
                      height: 1.5,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 22),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4CA562), Color(0xFF63C376)],
                      ),
                    ),
                    child: TextButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.thumb_up_alt_rounded,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Sí, estoy bien',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _SoftButton(
                    label: 'Necesito ayuda',
                    icon: Icons.notifications_active_rounded,
                    color: _red,
                    onPressed: () {
                      Navigator.pop(context);
                      showPendingDialog(
                        context,
                        'El aviso de ayuda a $trustedContactName estará disponible próximamente.',
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  Material(
                    type: MaterialType.transparency,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFF8040E9),
                        child: Text('M', style: TextStyle(color: Colors.white)),
                      ),
                      title: const Text(
                        'Enviar alerta a $trustedContactName',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        Navigator.pop(context);
                        showPendingDialog(
                          context,
                          'El envío de alertas estará disponible próximamente.',
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Si no respondes, tu contacto recibirá una alerta con tu última ubicación conocida.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.5,
                      color: scheme.onSurfaceVariant,
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
