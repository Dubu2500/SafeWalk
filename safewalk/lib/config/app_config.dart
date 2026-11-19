/// Supply private development values through --dart-define-from-file.
class AppConfig {
  static const orsApiKey = String.fromEnvironment('ORS_API_KEY');
  static const trackingBaseUrl = String.fromEnvironment(
    'TRACKING_BASE_URL',
    defaultValue: 'https://safewalk-fb1e9.web.app',
  );
  static void requireRouteKey() {
    if (orsApiKey.trim().isEmpty) {
      throw StateError(
        'Configura ORS_API_KEY para buscar destinos y calcular rutas. Consulta el README.',
      );
    }
  }
}
