import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safewalk/models/trusted_contact.dart';
import 'package:safewalk/providers/account_provider.dart';
import 'package:safewalk/providers/user_provider.dart';
import 'package:safewalk/services/account_repository.dart';

Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 50));

void main() {
  late FakeFirebaseFirestore db;
  late AccountRepository repository;
  setUp(() {
    db = FakeFirebaseFirestore();
    repository = AccountRepository(firestore: db);
  });
  test(
    'Creates and migrates Auth users without replacing edited profiles',
    () async {
      final user = MockUser(
        uid: 'ana',
        email: 'ana@example.com',
        displayName: 'Ana',
      );
      await repository.ensureUser(user);
      await repository.saveProfile(
        'ana',
        'Ana María',
        '3312345678',
        'Guadalajara',
      );
      final createdAt = (await repository.user('ana').get())
          .data()!['createdAt'];
      await repository.ensureUser(user);
      final data = (await repository.user('ana').get()).data()!;
      expect(data['name'], 'Ana María');
      expect(data['city'], 'Guadalajara');
      expect(data['createdAt'], createdAt);
      expect(data.containsKey('password'), isFalse);
    },
  );
  test(
    'Registration writes the Auth account into the user collection',
    () async {
      final auth = MockFirebaseAuth();
      final userProvider = UserProvider(repository: repository, auth: auth);
      await userProvider.register(
        name: 'Ana',
        email: 'ana@example.com',
        password: 'password123',
      );
      final data = (await repository.user(auth.currentUser!.uid).get()).data()!;
      expect(data['name'], 'Ana');
      expect(data['email'], 'ana@example.com');
      expect(data['primaryContactId'], isNull);
      userProvider.dispose();
    },
  );
  test(
    'Contact CRUD persists and deleting the primary clears its reference',
    () async {
      await repository.ensureUser(
        MockUser(uid: 'ana', email: 'ana@example.com'),
      );
      await repository.saveContact(
        'ana',
        const TrustedContact(
          id: '',
          name: 'Mamá',
          relationship: 'Familia',
          phone: '3312345678',
        ),
      );
      final contacts = repository.user('ana').collection('contacts');
      final id = (await contacts.get()).docs.single.id;
      await repository.saveContact(
        'ana',
        TrustedContact(
          id: id,
          name: 'María',
          relationship: 'Mamá',
          phone: '3398765432',
        ),
      );
      expect((await contacts.doc(id).get()).data()!['name'], 'María');
      await repository.setPrimary('ana', id);
      expect(
        (await repository.user('ana').get()).data()!['primaryContactId'],
        id,
      );
      expect(
        (await repository.user('other').collection('contacts').get()).docs,
        isEmpty,
      );
      await repository.deleteContact('ana', id);
      expect((await contacts.get()).docs, isEmpty);
      expect(
        (await repository.user('ana').get()).data()!['primaryContactId'],
        isNull,
      );
      await expectLater(repository.setPrimary('ana', id), throwsStateError);
    },
  );
  test('Provider observes profile and contacts, and clears data on sign-out', () async {
    final user = MockUser(
      uid: 'ana',
      email: 'ana@example.com',
      displayName: 'Ana',
    );
    final auth = MockFirebaseAuth(mockUser: user, signedIn: true);
    final userProvider = UserProvider(repository: repository, auth: auth);
    final account = AccountProvider(userProvider, repository: repository);
    await settle();
    expect(account.loading, isFalse);
    expect(account.error, isNull);
    expect(account.displayName, 'Ana');
    expect(account.contacts, isEmpty);
    await account.saveContact(
      const TrustedContact(
        id: 'one',
        name: 'Luis',
        relationship: 'Amigo',
        phone: '3312345678',
      ),
    );
    await settle();
    await account.setPrimary('one');
    await account.saveProfile('Ana María', '', 'Zapopan');
    await settle();
    expect(account.primaryContact?.name, 'Luis');
    expect(account.displayName, 'Ana María');
    await expectLater(
      () => account.saveContact(
        const TrustedContact(id: '', name: '', relationship: '', phone: 'x'),
      ),
      throwsArgumentError,
    );
    await userProvider.signOut();
    await settle();
    expect(account.profile, isNull);
    expect(account.contacts, isEmpty);
    expect(account.destinations, isEmpty);
    // A late update from the previous account must not repopulate the provider.
    await repository.user('ana').update({'city': 'Otra ciudad'});
    await settle();
    expect(account.profile, isNull);
    account.dispose();
    userProvider.dispose();
  });
  test('Destinations and statistics are read from Firestore', () async {
    final user = MockUser(uid: 'ana', email: 'ana@example.com');
    final auth = MockFirebaseAuth(mockUser: user, signedIn: true);
    final userProvider = UserProvider(repository: repository, auth: auth);
    final account = AccountProvider(userProvider, repository: repository);
    await settle();
    await account.addDestination('Casa', 'Mi dirección');
    await repository.user('ana').collection('trips').add({
      'status': 'completed',
    });
    await repository.user('ana').collection('trips').add({'status': 'active'});
    await settle();
    expect(account.destinations.single.subtitle, 'Mi dirección');
    expect(account.completedWalks, 1);
    await account.setPreference('darkMode', true);
    await settle();
    expect(account.darkMode, isTrue);
    account.dispose();
    userProvider.dispose();
  });
}
