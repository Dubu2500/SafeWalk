enum DestinationKind { home, map, recent }

class Destination {
  const Destination({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.kind,
  });

  final String id;
  final String title;
  final String subtitle;
  final String emoji;
  final DestinationKind kind;
}
