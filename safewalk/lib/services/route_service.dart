import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../config/app_config.dart';

class WalkingRoute {
  const WalkingRoute({
    required this.points,
    required this.distanceMeters,
    required this.durationSeconds,
  });

  final List<LatLng> points;
  final double distanceMeters;
  final double durationSeconds;

  // Distancia en metros desde un punto hasta la línea de la ruta.
  double distanceFrom(LatLng point) {
    if (points.isEmpty) return double.infinity;
    if (points.length == 1) {
      return const Distance().as(LengthUnit.Meter, point, points.first);
    }
    var shortest = double.infinity;
    for (var i = 0; i < points.length - 1; i++) {
      final distance = _distanceToSegment(point, points[i], points[i + 1]);
      if (distance < shortest) shortest = distance;
    }
    return shortest;
  }

  static double _distanceToSegment(LatLng p, LatLng a, LatLng b) {
    // Convierte a metros alrededor del punto p (suficiente para distancias cortas).
    const metersPerDegree = 111320.0;
    final cosLat = cos(p.latitude * pi / 180);
    double x(LatLng q) =>
        (q.longitude - p.longitude) * metersPerDegree * cosLat;
    double y(LatLng q) => (q.latitude - p.latitude) * metersPerDegree;

    final ax = x(a), ay = y(a), bx = x(b), by = y(b);
    final dx = bx - ax, dy = by - ay;
    final lengthSquared = dx * dx + dy * dy;
    final t = lengthSquared == 0
        ? 0.0
        : ((-ax * dx - ay * dy) / lengthSquared).clamp(0.0, 1.0);
    final cx = ax + t * dx, cy = ay + t * dy;
    return sqrt(cx * cx + cy * cy);
  }

  String get distanceLabel => distanceMeters >= 1000
      ? '${(distanceMeters / 1000).toStringAsFixed(1)} km'
      : '${distanceMeters.round()} m';

  String get durationLabel {
    final minutes = (durationSeconds / 60).ceil();
    if (minutes < 60) return '$minutes min';
    final hours = minutes ~/ 60;
    final rest = minutes % 60;
    return rest == 0 ? '$hours h' : '$hours h $rest min';
  }
}

class RouteService {
  static const _url =
      'https://api.heigit.org/openrouteservice/v2/directions/foot-walking/geojson';

  static Future<WalkingRoute> walkingRoute(LatLng from, LatLng to) async {
    AppConfig.requireRouteKey();
    final response = await http
        .post(
          Uri.parse(_url),
          headers: {
            'Authorization': AppConfig.orsApiKey,
            'Content-Type': 'application/json',
            'Accept': 'application/geo+json',
          },
          body: jsonEncode({
            // OpenRouteService usa el orden [longitud, latitud].
            'coordinates': [
              [from.longitude, from.latitude],
              [to.longitude, to.latitude],
            ],
          }),
        )
        .timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      throw Exception('No se pudo calcular la ruta (${response.statusCode}).');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final feature = (data['features'] as List).first as Map<String, dynamic>;
    final coordinates = feature['geometry']['coordinates'] as List;
    final summary = feature['properties']['summary'] as Map<String, dynamic>;

    return WalkingRoute(
      points: [
        for (final point in coordinates)
          LatLng((point[1] as num).toDouble(), (point[0] as num).toDouble()),
      ],
      distanceMeters: (summary['distance'] as num? ?? 0).toDouble(),
      durationSeconds: (summary['duration'] as num? ?? 0).toDouble(),
    );
  }
}
