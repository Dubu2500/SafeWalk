import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

import '../config/app_config.dart';

/// The random identifier is a bearer capability: never list or log it.
/// Sessions contain no phone, email or contact record and expire after 4 hours.
class LiveTripService {
  LiveTripService({FirebaseFirestore? firestore})
    : db = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore db;
  String newId() => base64UrlEncode(
    List<int>.generate(32, (_) => Random.secure().nextInt(256)),
  ).replaceAll('=', '');
  DocumentReference<Map<String, dynamic>> ref(String id) =>
      db.collection('liveTrips').doc(id);
  String link(String id) =>
      Uri.parse(AppConfig.trackingBaseUrl)
          .replace(path: '/track', fragment: id)
          .toString();
  Future<void> start(String id, String uid, LatLng point) => ref(id).set({
    'ownerUid': uid,
    'latitude': point.latitude,
    'longitude': point.longitude,
    'status': 'active',
    'alert': false,
    'updatedAt': FieldValue.serverTimestamp(),
    'expiresAt': Timestamp.fromDate(
      DateTime.now().add(const Duration(hours: 4)),
    ),
  });
  Future<void> position(String id, LatLng point) => ref(id).update({
    'latitude': point.latitude,
    'longitude': point.longitude,
    'updatedAt': FieldValue.serverTimestamp(),
  });
  Future<void> alert(String id, bool value) =>
      ref(id)
          .update({'alert': value, 'updatedAt': FieldValue.serverTimestamp()});
  Future<void> stop(String id) => ref(id).update({
    'status': 'ended',
    'alert': false,
    'updatedAt': FieldValue.serverTimestamp(),
  });
  Future<void> revoke(String id) => ref(id).delete();
}
