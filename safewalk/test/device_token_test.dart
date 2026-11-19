import 'dart:async';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safewalk/providers/account_provider.dart';
import 'package:safewalk/providers/device_token_provider.dart';
import 'package:safewalk/providers/user_provider.dart';
import 'package:safewalk/services/account_repository.dart';

Future<void> _settle() =>
    Future<void>.delayed(const Duration(milliseconds: 50));

void main() {
  test(
    'guarda el token del dispositivo y lo actualiza cuando cambia',
    () async {
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
      final refresh = StreamController<String>();
      final messages = StreamController<RemoteMessage>();
      final shown = <String>[];
      final tokens = DeviceTokenProvider(
        account,
        getToken: () async => 'token-1',
        onTokenRefresh: refresh.stream,
        onMessage: messages.stream,
        onForegroundMessage: (title, body) => shown.add('$title|$body'),
      );
      await _settle();

      var doc = await db.collection('users').doc('ana').get();
      expect(doc.data()?['fcmToken'], 'token-1');
      expect(tokens.token, 'token-1');

      refresh.add('token-2');
      await _settle();
      doc = await db.collection('users').doc('ana').get();
      expect(doc.data()?['fcmToken'], 'token-2');

      messages.add(
        const RemoteMessage(
          notification: RemoteNotification(title: 'Hola', body: 'Prueba'),
        ),
      );
      await _settle();
      expect(shown, ['Hola|Prueba']);

      await account.setPreference('notifications', false);
      await _settle();
      messages.add(
        const RemoteMessage(
          notification: RemoteNotification(title: 'Oculta', body: 'No'),
        ),
      );
      await _settle();
      expect(shown, ['Hola|Prueba']);

      tokens.dispose();
      account.dispose();
      user.dispose();
      await refresh.close();
      await messages.close();
    },
  );
}
