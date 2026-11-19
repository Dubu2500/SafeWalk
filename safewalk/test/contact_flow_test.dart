import 'dart:io';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:safewalk/main.dart';
import 'package:safewalk/providers/account_provider.dart';
import 'package:safewalk/providers/photo_provider.dart';
import 'package:safewalk/providers/user_provider.dart';
import 'package:safewalk/services/account_repository.dart';

void main() {
  testWidgets('Authenticated app supports the complete contact flow', (
    tester,
  ) async {
    final db = FakeFirebaseFirestore();
    final repository = AccountRepository(firestore: db);
    final auth = MockFirebaseAuth(
      mockUser: MockUser(
        uid: 'ana',
        email: 'ana@example.com',
        displayName: 'Ana',
      ),
      signedIn: true,
    );
    final user = UserProvider(repository: repository, auth: auth);
    final account = AccountProvider(user, repository: repository);
    final photos = PhotoProvider(
      user,
      baseDir: () async => Directory.systemTemp.createTemp('safewalk_flow'),
    );
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<UserProvider>.value(value: user),
          ChangeNotifierProvider<AccountProvider>.value(value: account),
          ChangeNotifierProvider<PhotoProvider>.value(value: photos),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Hola, Ana'), findsOneWidget);
    expect(
      find.text('Guarda tu primer destino para comenzar.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Contacto de confianza'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Agregar'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nombre'),
      'Luis',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Relación'),
      'Amigo',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Teléfono'),
      '3312345678',
    );
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    expect(find.text('Luis'), findsOneWidget);
    await tester.tap(find.byTooltip('Elegir como principal'));
    await tester.pumpAndSettle();
    expect(account.primaryContact?.name, 'Luis');
    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Editar'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nombre'),
      'Luis Pérez',
    );
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    expect(find.text('Luis Pérez'), findsOneWidget);
    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Eliminar'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Eliminar'));
    await tester.pumpAndSettle();
    expect(account.contacts, isEmpty);
    expect(account.primaryContact, isNull);
    expect(
      find.text('Aún no tienes contactos. Agrega el primero.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    account.dispose();
    user.dispose();
  });
}
