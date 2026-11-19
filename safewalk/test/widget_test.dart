import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safewalk/widgets/profile_header.dart';

void main() {
  testWidgets('Profile handles a new account without a display name', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProfileHeader(
            name: '',
            email: 'ana@example.com',
            onPhotoTap: () {},
          ),
        ),
      ),
    );
    expect(find.text('?'), findsOneWidget);
    expect(find.text('ana@example.com'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
