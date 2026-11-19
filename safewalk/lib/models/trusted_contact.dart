class TrustedContact {
  const TrustedContact({
    required this.id,
    required this.name,
    required this.relationship,
    required this.phone,
  });
  final String id, name, relationship, phone;
  factory TrustedContact.fromMap(String id, Map<String, dynamic> data) =>
      TrustedContact(
        id: id,
        name: data['name'] as String? ?? '',
        relationship: data['relationship'] as String? ?? '',
        phone: data['phone'] as String? ?? '',
      );
  Map<String, dynamic> toMap() => {
    'name': name.trim(),
    'relationship': relationship.trim(),
    'phone': phone.trim(),
  };
}
