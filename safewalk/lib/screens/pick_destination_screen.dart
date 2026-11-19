import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../models/destination.dart';
import '../services/geocoding_service.dart';
import '../widgets/safewalk_tile_layer.dart';

class PickDestinationScreen extends StatefulWidget {
  const PickDestinationScreen({super.key});

  @override
  State<PickDestinationScreen> createState() => _PickDestinationScreenState();
}

class _PickDestinationScreenState extends State<PickDestinationScreen> {
  // Centro de Guadalajara, mientras se obtiene la ubicación real.
  static const _fallbackCenter = LatLng(20.6767, -103.3475);

  final _mapController = MapController();
  final _tileLayer = buildSafeWalkTileLayer();
  final _search = TextEditingController();

  LatLng? _myLocation;
  LatLng? _selectedPoint;
  String? _selectedLabel;
  List<PlaceResult> _results = [];
  bool _mapReady = false;
  bool _searching = false;
  bool _loadingName = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMyLocation();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _loadMyLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return;
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }
      final position = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      final point = LatLng(position.latitude, position.longitude);
      setState(() => _myLocation = point);
      if (_mapReady) _mapController.move(point, 15);
    } catch (_) {
      // Si no hay ubicación, el mapa se queda en Guadalajara.
    }
  }

  Future<void> _searchPlaces(String text) async {
    final query = text.trim();
    if (query.isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _searching = true;
      _error = null;
    });
    try {
      final results = await GeocodingService.search(query, near: _myLocation);
      if (!mounted) return;
      setState(() {
        _results = results;
        if (results.isEmpty) _error = 'No encontramos ese lugar.';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  void _selectResult(PlaceResult place) {
    setState(() {
      _selectedPoint = place.point;
      _selectedLabel = place.label;
      _results = [];
    });
    _mapController.move(place.point, 16);
  }

  Future<void> _selectPoint(LatLng point) async {
    FocusScope.of(context).unfocus();
    setState(() {
      _selectedPoint = point;
      _selectedLabel = null;
      _results = [];
      _loadingName = true;
    });
    String? label;
    try {
      label = await GeocodingService.nameOf(point);
    } catch (_) {
      label = null;
    }
    if (!mounted || _selectedPoint != point) return;
    setState(() {
      _selectedLabel = label ??
          '${point.latitude.toStringAsFixed(5)}, ${point.longitude.toStringAsFixed(5)}';
      _loadingName = false;
    });
  }

  void _confirm() {
    final point = _selectedPoint;
    if (point == null) return;
    Navigator.pop(
      context,
      Destination(
        id: '',
        title: '',
        subtitle: _selectedLabel ?? 'Punto en el mapa',
        latitude: point.latitude,
        longitude: point.longitude,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final selectedPoint = _selectedPoint;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Elegir destino',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _fallbackCenter,
              initialZoom: 14,
              onMapReady: () {
                _mapReady = true;
                final myLocation = _myLocation;
                if (myLocation != null) _mapController.move(myLocation, 15);
              },
              onTap: (_, point) => _selectPoint(point),
            ),
            children: [
              _tileLayer,
              MarkerLayer(
                markers: [
                  if (_myLocation != null)
                    Marker(
                      point: _myLocation!,
                      width: 22,
                      height: 22,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF365DD8),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                      ),
                    ),
                  if (selectedPoint != null)
                    Marker(
                      point: selectedPoint,
                      width: 44,
                      height: 44,
                      alignment: Alignment.topCenter,
                      child: const Icon(
                        Icons.location_on_rounded,
                        color: Colors.red,
                        size: 44,
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
          Positioned(
            left: 16,
            right: 16,
            top: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Material(
                  elevation: 3,
                  borderRadius: BorderRadius.circular(20),
                  color: colors.surface,
                  child: TextField(
                    controller: _search,
                    textInputAction: TextInputAction.search,
                    onSubmitted: _searchPlaces,
                    decoration: InputDecoration(
                      hintText: 'Busca una dirección o lugar',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _searching
                          ? const Padding(
                              padding: EdgeInsets.all(14),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                ),
                              ),
                            )
                          : IconButton(
                              tooltip: 'Buscar',
                              icon: const Icon(Icons.arrow_forward_rounded),
                              onPressed: () => _searchPlaces(_search.text),
                            ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Material(
                      borderRadius: BorderRadius.circular(14),
                      color: colors.errorContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          _error!,
                          style: TextStyle(color: colors.onErrorContainer),
                        ),
                      ),
                    ),
                  ),
                if (_results.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Material(
                      elevation: 3,
                      borderRadius: BorderRadius.circular(16),
                      color: colors.surface,
                      clipBehavior: Clip.antiAlias,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 280),
                        child: ListView.separated(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemCount: _results.length,
                          separatorBuilder: (_, _) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final place = _results[index];
                            return ListTile(
                              leading: const Icon(Icons.place_outlined),
                              title: Text(place.label),
                              onTap: () => _selectResult(place),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Positioned(
            left: 16,
            right: 16,
            bottom: 170,
            child: MapTileErrorBanner(),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(24),
              color: colors.surface,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      selectedPoint == null
                          ? 'Toca el mapa o busca un lugar.'
                          : _loadingName
                          ? 'Buscando la dirección...'
                          : _selectedLabel ?? '',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: selectedPoint == null || _loadingName
                          ? null
                          : _confirm,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Usar este destino'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _myLocation == null
          ? null
          : Padding(
              padding: const EdgeInsets.only(bottom: 130),
              child: FloatingActionButton.small(
                tooltip: 'Mi ubicación',
                onPressed: () => _mapController.move(_myLocation!, 16),
                child: const Icon(Icons.my_location_rounded),
              ),
            ),
    );
  }
}
