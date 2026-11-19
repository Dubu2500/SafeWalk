import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

// Último error al descargar el mapa (para mostrarlo en pantalla).
final mapTileError = ValueNotifier<String?>(null);

// Capa del mapa: OpenStreetMap.
// Cada pantalla debe crearla UNA vez (como campo del State), no dentro de
// build(); si no, el mapa vuelve a descargar todo en cada redibujado.
TileLayer buildSafeWalkTileLayer() => TileLayer(
  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  // OpenStreetMap bloquea nombres genéricos como "com.example"; usamos uno propio.
  userAgentPackageName: 'mx.iteso.safewalk',
  maxNativeZoom: 19,
  // Sin caché en disco: la caché de flutter_map usa path_provider, que en este
  // proyecto truena en Android (ClassNotFoundException con jni) y deja el mapa gris.
  tileProvider: NetworkTileProvider(
    cachingProvider: const DisabledMapCachingProvider(),
  ),
  errorTileCallback: (tile, error, stackTrace) {
    debugPrint('No se pudo cargar el mapa (${tile.coordinates}): $error');
    mapTileError.value = '$error';
  },
);

// Aviso rojo que aparece sobre el mapa si las imágenes no se pueden descargar.
class MapTileErrorBanner extends StatelessWidget {
  const MapTileErrorBanner({super.key});

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<String?>(
    valueListenable: mapTileError,
    builder: (context, error, _) {
      if (error == null) return const SizedBox.shrink();
      return Material(
        color: Colors.red.shade700,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Text(
            'El mapa no cargó: $error',
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      );
    },
  );
}
