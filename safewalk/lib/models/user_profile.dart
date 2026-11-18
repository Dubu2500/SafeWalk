import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  const UserProfile({
    required this.name,
    required this.email,
    required this.phone,
    required this.city,
    required this.createdAt,
    this.primaryContactId,
  });
  final String name, email, phone, city;
  final DateTime? createdAt;
  final String? primaryContactId;
  String get memberSince => createdAt == null
      ? '—'
      : '${createdAt!.month.toString().padLeft(2, '0')}/${createdAt!.year}';
  factory UserProfile.fromMap(Map<String, dynamic> data) => UserProfile(
    name: data['name'] as String? ?? '',
    email: data['email'] as String? ?? '',
    phone: data['phone'] as String? ?? '',
    city: data['city'] as String? ?? '',
    createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    primaryContactId: data['primaryContactId'] as String?,
  );
}
