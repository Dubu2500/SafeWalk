import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/trusted_contact.dart';

class AccountRepository {
  AccountRepository({FirebaseFirestore? firestore})
    : db = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore db;
  DocumentReference<Map<String, dynamic>> user(String uid) =>
      db.collection('users').doc(uid);

  // Transactional creation also migrates existing Auth accounts on first login.
  // Existing profile fields are preserved on subsequent logins.
  Future<void> ensureUser(User account, {String? name}) async {
    final ref = user(account.uid);
    await db.runTransaction((tx) async {
      final snapshot = await tx.get(ref);
      if (!snapshot.exists) {
        tx.set(ref, {
          'name': name ?? account.displayName ?? '',
          'email': account.email ?? '',
          'phone': account.phoneNumber ?? '',
          'city': '',
          'primaryContactId': null,
          'createdAt': Timestamp.fromDate(
            account.metadata.creationTime ?? DateTime.now(),
          ),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        tx.update(ref, {
          'email': account.email ?? '',
          'name': ?name,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  Future<void> saveProfile(
    String uid,
    String name,
    String phone,
    String city,
  ) => user(uid).update({
    'name': name.trim(),
    'phone': phone.trim(),
    'city': city.trim(),
    'updatedAt': FieldValue.serverTimestamp(),
  });

  Future<void> saveContact(String uid, TrustedContact contact) async {
    final collection = user(uid).collection('contacts');
    final ref = contact.id.isEmpty
        ? collection.doc()
        : collection.doc(contact.id);
    await ref.set(contact.toMap());
  }

  Future<void> setPrimary(String uid, String id) =>
      db.runTransaction((tx) async {
        final ref = user(uid);
        final contact = await tx.get(ref.collection('contacts').doc(id));
        if (!contact.exists) throw StateError('El contacto ya no existe.');
        tx.update(ref, {'primaryContactId': id});
      });

  Future<void> deleteContact(String uid, String id) =>
      db.runTransaction((tx) async {
        final ref = user(uid);
        final profile = await tx.get(ref);
        tx.delete(ref.collection('contacts').doc(id));
        if (profile.data()?['primaryContactId'] == id) {
          tx.update(ref, {'primaryContactId': null});
        }
      });

  Future<void> addDestination(
    String uid,
    String title,
    String address, {
    double? lat,
    double? lng,
  }) async {
    await user(uid).collection('destinations').add({
      'title': title.trim(),
      'address': address.trim(),
      if (lat != null && lng != null) 'lat': lat,
      if (lat != null && lng != null) 'lng': lng,
    });
  }
}
