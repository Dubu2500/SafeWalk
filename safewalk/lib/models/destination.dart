class Destination {
  const Destination({
    required this.id,
    required this.title,
    required this.subtitle,
  });
  final String id, title, subtitle;
  String get emoji => '📍';
  factory Destination.fromMap(String id, Map<String, dynamic> data) =>
      Destination(
        id: id,
        title: data['title'] as String? ?? '',
        subtitle: data['address'] as String? ?? '',
      );
}
