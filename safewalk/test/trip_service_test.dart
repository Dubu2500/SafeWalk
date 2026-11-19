import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:safewalk/providers/account_provider.dart';
import 'package:safewalk/providers/user_provider.dart';
import 'package:safewalk/services/account_repository.dart';
import 'package:safewalk/services/trip_service.dart';
import 'package:safewalk/widgets/help_sheet.dart';

void main() {
  test('guardar un trayecto aumenta el contador del perfil', () async {
    final db = FakeFirebaseFirestore();
    final repository = AccountRepository(firestore: db);
    final user = UserProvider(
      repository: repository,
      auth: MockFirebaseAuth(
        mockUser: MockUser(uid: 'ana', email: 'ana@example.com'),
        signedIn: true,
      ),
    );
    final account = AccountProvider(user, repository: repository);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(account.completedWalks, 0);

    await TripService(firestore: db).saveTrip(
      'ana',
      destination: 'Casa',
      startedAt: DateTime(2026, 11, 18, 20),
      arrived: true,
    );
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(account.completedWalks, 1);
    final trip = (await db.collection('users/ana/trips').get()).docs.single;
    expect(trip.data()['destination'], 'Casa');
    expect(trip.data()['arrived'], true);

    account.dispose();
    user.dispose();
  });

  test('el mensaje de ayuda incluye la ubicación', () {
    final message = helpMessage(const LatLng(20.6767, -103.3475));
    expect(
      message,
      contains('https://maps.google.com/?q=20.676700,-103.347500'),
    );
    expect(helpMessage(null), isNot(contains('http')));
  });
}
