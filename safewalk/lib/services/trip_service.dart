import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

class TripService {
  TripService({FirebaseFirestore? firestore})
    : db = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore db;

  static String mapLink(LatLng point) =>
      'https://maps.google.com/?q=${point.latitude.toStringAsFixed(6)},${point.longitude.toStringAsFixed(6)}';

  Future<void> saveTrip(
    String uid, {
    required String destination,
    required DateTime startedAt,
    required bool arrived,
  }) => db.collection('users').doc(uid).collection('trips').add({
    'destination': destination,
    'status': 'completed',
    'arrived': arrived,
    'startedAt': Timestamp.fromDate(startedAt),
    'endedAt': FieldValue.serverTimestamp(),
  });
}
