import 'package:flutter/material.dart';

import 'dart:io';

import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:safewalk/providers/photo_provider.dart';
import 'package:safewalk/providers/user_provider.dart';
import 'package:safewalk/services/account_repository.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:safewalk/widgets/profile_header.dart';

void main() {
  testWidgets('Profile handles a new account without a display name', (
    tester,
  ) async {
    final user = UserProvider(
      repository: AccountRepository(firestore: FakeFirebaseFirestore()),
      auth: MockFirebaseAuth(),
    );
    final photos = PhotoProvider(
      user,
      baseDir: () async => Directory.systemTemp.createTemp('safewalk_header'),
    );
    await tester.pumpWidget(
      ChangeNotifierProvider<PhotoProvider>.value(
        value: photos,
        child: MaterialApp(
          home: Scaffold(
            body: ProfileHeader(
              name: '',
              email: 'ana@example.com',
              onPhotoTap: () {},
            ),
          ),
        ),
      ),
    );
    expect(find.text('?'), findsOneWidget);
    expect(find.text('ana@example.com'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
