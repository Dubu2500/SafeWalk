import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:safewalk/providers/user_provider.dart';
import 'package:safewalk/screens/login_screen.dart';
import 'package:safewalk/services/account_repository.dart';

void main() {
  testWidgets('recuperar contraseña valida el correo y confirma el envío', (
    tester,
  ) async {
    final user = UserProvider(
      repository: AccountRepository(firestore: FakeFirebaseFirestore()),
      auth: MockFirebaseAuth(),
    );
    await tester.pumpWidget(
      ChangeNotifierProvider<UserProvider>.value(
        value: user,
        child: const MaterialApp(home: LoginScreen()),
      ),
    );

    await tester.tap(find.text('¿Olvidaste tu contraseña?'));
    await tester.pumpAndSettle();
    expect(find.text('Recuperar contraseña'), findsOneWidget);

    final field = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(TextField),
    );
    await tester.enterText(field, 'correo-malo');
    await tester.tap(find.text('Enviar'));
    await tester.pump();
    expect(find.text('Escribe un correo válido.'), findsOneWidget);

    await tester.enterText(field, 'ana@example.com');
    await tester.tap(find.text('Enviar'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.textContaining('Te enviamos un correo'), findsOneWidget);
  });
}
