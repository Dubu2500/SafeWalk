class Destination {
  const Destination({
    required this.id,
    required this.title,
    required this.subtitle,
    this.latitude,
    this.longitude,
  });
  final String id, title, subtitle;
  final double? latitude;
  final double? longitude;
  String get emoji => '📍';
  bool get hasLocation => latitude != null && longitude != null;
  factory Destination.fromMap(String id, Map<String, dynamic> data) =>
      Destination(
        id: id,
        title: data['title'] as String? ?? '',
        subtitle: data['address'] as String? ?? '',
        latitude: (data['lat'] as num?)?.toDouble(),
        longitude: (data['lng'] as num?)?.toDouble(),
      );
}
