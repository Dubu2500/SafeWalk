import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/destination.dart';
import '../models/trusted_contact.dart';
import '../providers/account_provider.dart';
import '../services/geocoding_service.dart';
import '../services/route_service.dart';
import '../services/trip_service.dart';
import '../services/live_trip_service.dart';
import '../services/journey_reminder.dart';
import '../widgets/safewalk_tile_layer.dart';
import '../widgets/friend_card.dart';
import '../widgets/help_sheet.dart';
import '../widgets/off_route.dart';
import '../widgets/trip_header.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late final JourneyReminder _reminder = JourneyReminder(_showJourneyReminder);
  LiveTripService? _live;
  String? _liveId;
  bool _sharingBusy = false;
  Future<void> _liveWrites = Future<void>.value();
  DateTime? _lastUpload;
  // Centro de Guadalajara, mientras se obtiene la ubicación real.
  static const _fallbackCenter = LatLng(20.6767, -103.3475);
  // Metros para considerar que llegaste o que te saliste de la ruta.
  static const _arrivalRadius = 30.0;
  static const _offRouteDistance = 50.0;
  // Lecturas seguidas fuera de ruta antes de avisar.
  static const _offRouteReadings = 3;

  final _mapController = MapController();
  final _tileLayer = buildSafeWalkTileLayer();
  StreamSubscription<Position>? _positionSubscription;

  Destination? _destination;
  LatLng? _destinationPoint;
  String _contactName = 'Tu contacto';
  TrustedContact? _contact;
  final _startedAt = DateTime.now();
  bool _finishing = false;
  bool _started = false;
  LatLng? _myLocation;
  WalkingRoute? _route;
  bool _mapReady = false;
  bool _loading = true;
  bool _recalculating = false;
  bool _alertOpen = false;
  bool _arrived = false;
  int _offRouteCount = 0;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentAccount = context.watch<AccountProvider>();
    _reminder.setEnabled(
      _route != null && !_finishing && currentAccount.journeyReminders,
    );
    if (_started) return;
    _started = true;
    final account = context.read<AccountProvider>();
    _destination = account.selectedDestination;
    _contact = account.primaryContact;
    _contactName = _contact?.name ?? _contactName;
    _start();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _reminder.dispose();
    final id = _liveId;
    if (id != null) {
      _liveId = null;
      _enqueueLive(() => _live!.stop(id));
    }
    super.dispose();
  }

  // Usa las coordenadas guardadas o, si no hay, busca la dirección.
  Future<LatLng> _resolveDestination(LatLng near) async {
    final destination = _destination;
    if (destination == null) {
      throw Exception('Elige un destino en la pantalla de inicio.');
    }
    if (destination.hasLocation) {
      return LatLng(destination.latitude!, destination.longitude!);
    }
    final places = await GeocodingService.search(
      destination.subtitle,
      near: near,
    );
    if (places.isEmpty) {
      throw Exception('No encontramos la dirección de este destino.');
    }
    return places.first.point;
  }

  String? get _arrivalTime {
    final route = _route;
    if (route == null) return null;
    final arrival = DateTime.now().add(
      Duration(seconds: route.durationSeconds.round()),
    );
    return TimeOfDay.fromDateTime(arrival).format(context);
  }

  void _retry() {
    setState(() {
      _loading = true;
      _error = null;
    });
    _start();
  }

  Future<void> _start() async {
    try {
      final position = await _currentPosition();
      final myLocation = LatLng(position.latitude, position.longitude);
      final destinationPoint = await _resolveDestination(myLocation);
      final route = await RouteService.walkingRoute(
        myLocation,
        destinationPoint,
      );
      if (!mounted) return;
      setState(() {
        _myLocation = myLocation;
        _destinationPoint = destinationPoint;
        _route = route;
        _loading = false;
      });
      _fitRoute();
      _listenToPosition();
      _reminder.setEnabled(context.read<AccountProvider>().journeyReminders);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<Position> _currentPosition() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw Exception('Activa la ubicación de tu celular.');
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception('SafeWalk necesita permiso de ubicación.');
    }
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  void _listenToPosition() {
    _positionSubscription?.cancel();
    _positionSubscription =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10,
          ),
        ).listen((position) {
          if (!mounted) return;
          final location = LatLng(position.latitude, position.longitude);
          setState(() => _myLocation = location);
          _checkProgress(location);
          final id = _liveId;
          final now = DateTime.now();
          if (id != null &&
              (_lastUpload == null ||
                  now.difference(_lastUpload!) >= const Duration(seconds: 5))) {
            _lastUpload = now;
            _enqueueLive(() => _live!.position(id, location));
          }
        });
  }

  void _checkProgress(LatLng location) {
    final route = _route;
    final destinationPoint = _destinationPoint;
    if (route == null || destinationPoint == null) return;
    if (_arrived || _alertOpen || _recalculating) return;

    final toDestination = const Distance().as(
      LengthUnit.Meter,
      location,
      destinationPoint,
    );
    if (toDestination <= _arrivalRadius) {
      _arrive();
      return;
    }

    if (route.distanceFrom(location) > _offRouteDistance) {
      _offRouteCount++;
    } else {
      _offRouteCount = 0;
    }
    if (_offRouteCount >= _offRouteReadings) _handleOffRoute();
  }

  Future<void> _handleOffRoute() async {
    if (_alertOpen) return;
    _alertOpen = true;
    final response = await showOffRouteDialog(
      context,
      _contactName,
      sharing: _liveId != null,
    );
    if (!mounted) return;
    final id = _liveId;
    if (response != OffRouteResponse.safe) {
      if (id != null) await _enqueueLive(() => _live!.alert(id, true));
      if (mounted) {
        await showHelpSheet(context, contact: _contact, location: _myLocation);
      }
    } else if (id != null) {
      await _enqueueLive(() => _live!.alert(id, false));
    }
    _alertOpen = false;
    _offRouteCount = 0;
    if (mounted) await _recalculate();
  }

  Future<void> _recalculate() async {
    final myLocation = _myLocation;
    final destinationPoint = _destinationPoint;
    if (myLocation == null || destinationPoint == null) return;
    setState(() => _recalculating = true);
    try {
      final route = await RouteService.walkingRoute(
        myLocation,
        destinationPoint,
      );
      if (!mounted) return;
      setState(() => _route = route);
      _fitRoute();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(error.toString().replaceFirst('Exception: ', '')),
          ),
        );
    } finally {
      if (mounted) setState(() => _recalculating = false);
    }
  }

  Future<void> _arrive() async {
    _arrived = true;
    await _positionSubscription?.cancel();
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.check_circle_rounded, color: Colors.green),
        title: const Text('¡Llegaste!'),
        content: Text(
          'Llegaste a ${_destination?.title ?? 'tu destino'}. '
          'Puedes avisar a $_contactName antes de finalizar.',
        ),
        actions: [
          if (_contact != null)
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                sendSms(
                  _contact!.phone,
                  'Ya llegué a ${_destination?.title ?? 'mi destino'}, estoy bien.',
                );
              },
              child: Text('Avisar a $_contactName'),
            ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Finalizar SafeWalk'),
          ),
        ],
      ),
    );
    await _finish(arrived: true);
  }

  Future<void> _finish({required bool arrived}) async {
    if (_finishing) return;
    setState(() => _finishing = true);
    _reminder.setEnabled(false);
    final account = context.read<AccountProvider>();
    final messenger = ScaffoldMessenger.of(context);
    try {
      final id = _liveId;
      if (id != null) {
        if (!await _enqueueLive(() => _live!.stop(id))) {
          throw StateError('sharing-stop');
        }
        _liveId = null;
      }
      await TripService(firestore: account.repository.db).saveTrip(
        account.uid,
        destination: _destination?.title ?? 'Destino',
        startedAt: _startedAt,
        arrived: arrived,
      );
      messenger.showSnackBar(
        const SnackBar(content: Text('Trayecto guardado.')),
      );
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('No se pudo guardar el trayecto. Puedes reintentar.'),
        ),
      );
      if (mounted) setState(() => _finishing = false);
      _reminder.setEnabled(account.journeyReminders);
      return;
    }
    if (mounted) Navigator.pop(context);
  }

  Future<bool> _enqueueLive(Future<void> Function() action) {
    final operation = _liveWrites.then(
      (_) => action().timeout(const Duration(seconds: 15)),
    );
    _liveWrites = operation.catchError((Object error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No se pudo actualizar el enlace. Revisa la conexión.',
            ),
          ),
        );
      }
    });
    return operation.then((_) => true, onError: (Object _) => false);
  }

  void _showJourneyReminder() {
    if (!mounted ||
        _finishing ||
        _alertOpen ||
        !context.read<AccountProvider>().journeyReminders) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 15),
        content: const Text(
          '¿Ya llegaste? Recuerda avisar a tu contacto y finalizar tu SafeWalk.',
        ),
        action: SnackBarAction(
          label: 'Avisar',
          onPressed: () async {
            final contact = _contact;
            if (contact != null) {
              await sendSms(
                contact.phone,
                'Sigo mi trayecto con SafeWalk. Te avisaré al llegar.',
              );
            }
          },
        ),
      ),
    );
  }

  Future<void> _requestHelp() async {
    final id = _liveId;
    if (id != null) await _enqueueLive(() => _live!.alert(id, true));
    if (mounted) {
      await showHelpSheet(context, contact: _contact, location: _myLocation);
    }
  }

  Future<void> _stopSharing() async {
    final id = _liveId;
    if (id == null || _sharingBusy) return;
    setState(() => _sharingBusy = true);
    final revoked = await _enqueueLive(() => _live!.revoke(id));
    if (mounted) {
      setState(() {
        _sharingBusy = false;
        if (revoked) _liveId = null;
      });
    }
  }

  Future<void> _shareTrip() async {
    final location = _myLocation;
    if (location == null || _sharingBusy) return;
    final account = context.read<AccountProvider>();
    setState(() => _sharingBusy = true);
    try {
      _live ??= LiveTripService(firestore: account.repository.db);
      if (_liveId == null) {
        final accepted = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Compartir ubicación en vivo'),
            content: const Text(
              'Quien tenga el enlace podrá ver tu ubicación y las alertas. Envíalo solo a tu contacto. Caduca en 4 horas; puedes detenerlo antes. El contacto debe mantener la página abierta para ver los avisos.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Crear enlace'),
              ),
            ],
          ),
        );
        if (accepted != true || !mounted) return;
        final id = _live!.newId();
        await _live!
            .start(id, account.uid, location)
            .timeout(const Duration(seconds: 15));
        if (!mounted) {
          await _live!.revoke(id);
          return;
        }
        setState(() => _liveId = id);
      }
      if (!mounted) return;
      final box = context.findRenderObject() as RenderBox?;
      await SharePlus.instance.share(
        ShareParams(
          text:
              'Sigue mi trayecto de SafeWalk en tiempo real: ${_live!.link(_liveId!)}',
          subject: 'Mi trayecto en SafeWalk',
          sharePositionOrigin: box == null
              ? null
              : box.localToGlobal(Offset.zero) & box.size,
        ),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No se pudo compartir. Revisa la configuración de Firebase Hosting y las reglas.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _sharingBusy = false);
    }
  }

  void _centerOnMe() {
    final myLocation = _myLocation;
    if (!_mapReady || myLocation == null) return;
    _mapController.move(myLocation, 17);
  }

  void _fitRoute() {
    final route = _route;
    if (!_mapReady || route == null || route.points.length < 2) return;
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds.fromPoints(route.points),
        padding: const EdgeInsets.all(40),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final route = _route;
    final destinationPoint = _destinationPoint;

    return Scaffold(
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TripHeader(arrival: _arrivalTime),
              SizedBox(
                height: 380,
                child: Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _myLocation ?? _fallbackCenter,
                        initialZoom: 15,
                        onMapReady: () {
                          _mapReady = true;
                          _fitRoute();
                        },
                      ),
                      children: [
                        _tileLayer,
                        if (route != null)
                          PolylineLayer(
                            polylines: [
                              Polyline(
                                points: route.points,
                                strokeWidth: 5,
                                color: const Color(0xFF365DD8),
                              ),
                            ],
                          ),
                        MarkerLayer(
                          markers: [
                            if (destinationPoint != null)
                              Marker(
                                point: destinationPoint,
                                width: 44,
                                height: 44,
                                alignment: Alignment.topCenter,
                                child: const Icon(
                                  Icons.location_on_rounded,
                                  color: Colors.red,
                                  size: 44,
                                ),
                              ),
                            if (_myLocation != null)
                              Marker(
                                point: _myLocation!,
                                width: 22,
                                height: 22,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF365DD8),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 3,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const RichAttributionWidget(
                          attributions: [
                            TextSourceAttribution('OpenStreetMap contributors'),
                          ],
                        ),
                      ],
                    ),
                    const Positioned(
                      left: 12,
                      right: 12,
                      top: 60,
                      child: MapTileErrorBanner(),
                    ),
                    if (_loading || _recalculating)
                      Container(
                        color: colors.surface.withValues(alpha: 0.6),
                        alignment: Alignment.center,
                        child: const CircularProgressIndicator(),
                      ),
                    if (_error != null)
                      Container(
                        color: colors.surface.withValues(alpha: 0.9),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_error!, textAlign: TextAlign.center),
                            const SizedBox(height: 12),
                            FilledButton(
                              onPressed: _retry,
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      ),
                    if (route != null)
                      Positioned(
                        left: 16,
                        bottom: 16,
                        child: Chip(
                          label: Text(
                            '${route.distanceLabel} · ${route.durationLabel}',
                          ),
                        ),
                      ),
                    if (_route != null)
                      Positioned(
                        right: 12,
                        bottom: 48,
                        child: Column(
                          children: [
                            IconButton.filledTonal(
                              tooltip: 'Mi ubicación',
                              onPressed: _centerOnMe,
                              icon: const Icon(Icons.my_location_rounded),
                            ),
                            IconButton.filledTonal(
                              tooltip: 'Ver toda la ruta',
                              onPressed: _fitRoute,
                              icon: const Icon(Icons.route_rounded),
                            ),
                          ],
                        ),
                      ),
                    Positioned(
                      right: 16,
                      top: 16,
                      child: ActionChip(
                        label: const Text('Simular fuera de ruta'),
                        onPressed: _route == null ? null : _handleOffRoute,
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
                    CompanionCard(name: _contactName),
                    const SizedBox(height: 14),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                      ),
                      onPressed: _sharingBusy || _myLocation == null
                          ? null
                          : _shareTrip,
                      icon: const Icon(Icons.share_location_rounded),
                      label: Text(
                        _liveId == null
                            ? 'Compartir viaje'
                            : 'Compartir enlace en vivo',
                      ),
                    ),
                    if (_liveId != null)
                      TextButton(
                        onPressed: _sharingBusy ? null : _stopSharing,
                        child: const Text('Detener ubicación compartida'),
                      ),
                    const SizedBox(height: 12),
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.red.shade50,
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                      ),
                      onPressed: _requestHelp,
                      child: const Text('Necesito ayuda'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                      ),
                      onPressed: _finishing
                          ? null
                          : () => _finish(arrived: false),
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
