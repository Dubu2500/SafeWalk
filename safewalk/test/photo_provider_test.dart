import 'dart:io';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safewalk/providers/photo_provider.dart';
import 'package:safewalk/providers/user_provider.dart';
import 'package:safewalk/services/account_repository.dart';

void main() {
  test('carga y quita la foto local del usuario actual', () async {
    final base = await Directory.systemTemp.createTemp('safewalk_photo');
    final photoDir = Directory('${base.path}/ProfilePhotos')..createSync();
    File('${photoDir.path}/ana_100.jpg').writeAsBytesSync([1, 2, 3]);
    File('${photoDir.path}/luis_200.jpg').writeAsBytesSync([4, 5, 6]);

    final user = UserProvider(
      repository: AccountRepository(firestore: FakeFirebaseFirestore()),
      auth: MockFirebaseAuth(
        mockUser: MockUser(uid: 'ana', email: 'ana@example.com'),
        signedIn: true,
      ),
    );
    final photos = PhotoProvider(user, baseDir: () async => base);
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(photos.photo?.path, endsWith('ana_100.jpg'));

    await photos.removePhoto();
    expect(photos.photo, isNull);
    expect(File('${photoDir.path}/ana_100.jpg').existsSync(), isFalse);
    expect(File('${photoDir.path}/luis_200.jpg').existsSync(), isTrue);

    photos.dispose();
    user.dispose();
    await base.delete(recursive: true);
  });
}
