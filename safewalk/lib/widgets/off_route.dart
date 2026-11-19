import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

enum OffRouteResponse { safe, help, timedOut }

Future<OffRouteResponse> showOffRouteDialog(
  BuildContext context,
  String contactName, {
  Duration timeout = const Duration(seconds: 20),
  bool sharing = false,
}) async =>
    await showDialog<OffRouteResponse>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _OffRouteDialog(
        contactName: contactName,
        timeout: timeout,
        sharing: sharing,
      ),
    ) ??
    OffRouteResponse.safe;

class _OffRouteDialog extends StatefulWidget {
  const _OffRouteDialog({
    required this.contactName,
    required this.timeout,
    required this.sharing,
  });
  final String contactName;
  final Duration timeout;
  final bool sharing;
  @override
  State<_OffRouteDialog> createState() => _OffRouteDialogState();
}

class _OffRouteDialogState extends State<_OffRouteDialog>
    with WidgetsBindingObserver {
  late final DateTime _deadline;
  Timer? _timer;
  int _seconds = 20;
  bool _closed = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _deadline = DateTime.now().add(widget.timeout);
    _seconds = widget.timeout.inSeconds;
    _timer = Timer.periodic(const Duration(milliseconds: 200), (_) => _tick());
  }

  void _tick() {
    if (!mounted || _closed) return;
    final remaining = min(
      _deadline.difference(DateTime.now()).inMilliseconds,
      widget.timeout.inMilliseconds - (_timer?.tick ?? 0) * 200,
    );
    if (remaining <= 0) {
      _close(OffRouteResponse.timedOut);
      return;
    }
    final next = (remaining / 1000).ceil();
    if (_seconds != next) setState(() => _seconds = next);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _tick();
  }

  void _close(OffRouteResponse response) {
    if (_closed) return;
    _closed = true;
    _timer?.cancel();
    Navigator.pop(context, response);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    child: AlertDialog(
      icon: const Icon(Icons.warning_amber_rounded, color: Colors.orange),
      title: const Text('¿Todo está bien?'),
      content: Text(
        'Estás fuera de tu ruta. Responde en 00:${_seconds.toString().padLeft(2, '0')}.\n\n'
        '${widget.sharing ? 'Si no respondes, la alerta aparecerá automáticamente en el enlace que compartiste con ${widget.contactName}.' : 'Comparte primero tu viaje para que tu contacto pueda recibir alertas en el enlace. Si no respondes, abriremos las opciones de ayuda.'}',
      ),
      actions: [
        TextButton(
          onPressed: () => _close(OffRouteResponse.help),
          child: const Text('Necesito ayuda'),
        ),
        FilledButton(
          onPressed: () => _close(OffRouteResponse.safe),
          child: const Text('Sí, estoy bien'),
        ),
      ],
    ),
  );
}
