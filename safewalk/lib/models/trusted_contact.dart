class TrustedContact {
  const TrustedContact({
    required this.id,
    required this.name,
    required this.relationship,
    required this.phone,
    this.available = true,
  });

  final String id;
  final String name;
  final String relationship;
  final String phone;
  final bool available;
}
