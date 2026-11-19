import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:safewalk/config/app_config.dart';
import 'package:safewalk/services/live_trip_service.dart';
import 'package:safewalk/services/journey_reminder.dart';
import 'package:safewalk/widgets/off_route.dart';
import 'package:flutter/material.dart';

void main() {
  test(
    'La configuración ausente no rompe la compilación y explica qué falta',
    () {
      if (AppConfig.orsApiKey.isEmpty) {
        expect(AppConfig.requireRouteKey, throwsA(isA<StateError>()));
      } else {
        expect(AppConfig.requireRouteKey, returnsNormally);
      }
    },
  );
  test('El mismo enlace recibe ubicación, alerta y finalización', () async {
    final db = FakeFirebaseFirestore();
    final service = LiveTripService(firestore: db);
    final id = service.newId();
    expect(id, matches(RegExp(r'^[A-Za-z0-9_-]{43}$')));
    expect(service.newId(), isNot(id));
    expect(Uri.parse(service.link(id)).fragment, id);
    await service.start(id, 'owner', const LatLng(20, -103));
    await service.position(id, const LatLng(21, -104));
    await service.alert(id, true);
    final data = (await service.ref(id).get()).data()!;
    expect(data['latitude'], 21);
    expect(data['alert'], true);
    expect(data.containsKey('phone'), isFalse);
    await service.stop(id);
    expect((await service.ref(id).get()).data()!['status'], 'ended');
    await service.revoke(id);
    expect((await service.ref(id).get()).exists, isFalse);
  });
  testWidgets('La cuenta regresiva vence y no deja temporizadores', (
    tester,
  ) async {
    OffRouteResponse? response;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              response = await showOffRouteDialog(
                context,
                'Ana',
                timeout: const Duration(seconds: 2),
                sharing: true,
              );
            },
            child: const Text('Abrir'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Abrir'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(response, OffRouteResponse.timedOut);
  });
  testWidgets('Responder estoy bien cancela la cuenta regresiva', (
    tester,
  ) async {
    OffRouteResponse? response;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              response = await showOffRouteDialog(context, 'Ana');
            },
            child: const Text('Abrir'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sí, estoy bien'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 25));
    expect(response, OffRouteResponse.safe);
  });
  testWidgets('La preferencia activa y cancela recordatorios sin duplicarlos', (
    tester,
  ) async {
    var count = 0;
    final reminders = JourneyReminder(
      () => count++,
      interval: const Duration(seconds: 1),
    );
    reminders.setEnabled(true);
    reminders.setEnabled(true);
    await tester.pump(const Duration(seconds: 2));
    expect(count, 2);
    reminders.setEnabled(false);
    await tester.pump(const Duration(seconds: 2));
    expect(count, 2);
    reminders.setEnabled(true);
    await tester.pump(const Duration(seconds: 1));
    expect(count, 3);
    reminders.dispose();
    await tester.pump(const Duration(seconds: 2));
    expect(count, 3);
  });
}
