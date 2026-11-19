import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../config/app_config.dart';

class PlaceResult {
  const PlaceResult({required this.label, required this.point});

  final String label;
  final LatLng point;
}

class GeocodingService {
  static const _baseUrl = 'https://api.heigit.org/pelias/v1';

  static Future<List<PlaceResult>> search(String text, {LatLng? near}) async {
    final uri = Uri.parse('$_baseUrl/search').replace(
      queryParameters: {
        'api_key': AppConfig.orsApiKey,
        'text': text,
        'boundary.country': 'MX',
        'size': '8',
        if (near != null) 'focus.point.lat': '${near.latitude}',
        if (near != null) 'focus.point.lon': '${near.longitude}',
      },
    );
    return _places(await _get(uri));
  }

  static Future<String?> nameOf(LatLng point) async {
    final uri = Uri.parse('$_baseUrl/reverse').replace(
      queryParameters: {
        'api_key': AppConfig.orsApiKey,
        'point.lat': '${point.latitude}',
        'point.lon': '${point.longitude}',
        'size': '1',
      },
    );
    final places = _places(await _get(uri));
    return places.isEmpty ? null : places.first.label;
  }

  static Future<Map<String, dynamic>> _get(Uri uri) async {
    AppConfig.requireRouteKey();
    final response = await http
        .get(uri, headers: {'Authorization': AppConfig.orsApiKey})
        .timeout(const Duration(seconds: 20));
    if (response.statusCode != 200) {
      throw Exception('No se pudo buscar el lugar (${response.statusCode}).');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  static List<PlaceResult> _places(Map<String, dynamic> data) => [
    for (final feature in data['features'] as List)
      PlaceResult(
        label: feature['properties']['label'] as String? ?? 'Lugar sin nombre',
        point: LatLng(
          (feature['geometry']['coordinates'][1] as num).toDouble(),
          (feature['geometry']['coordinates'][0] as num).toDouble(),
        ),
      ),
  ];
}
