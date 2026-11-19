import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/destination.dart';
import '../models/trusted_contact.dart';
import '../models/user_profile.dart';
import '../services/account_repository.dart';
import 'user_provider.dart';

class AccountProvider extends ChangeNotifier {
  AccountProvider(this.auth, {AccountRepository? repository})
    : repository = repository ?? AccountRepository() {
    auth.addListener(_authChanged);
    _authChanged();
  }
  final UserProvider auth;
  final AccountRepository repository;
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  String? _uid;
  int _generation = 0;
  bool _disposed = false;
  bool loading = true;
  String? error;
  UserProfile? profile;
  List<TrustedContact> contacts = [];
  List<Destination> destinations = [];
  String? selectedDestinationId;
  int completedWalks = 0;
  Map<String, dynamic> _preferences = {};
  bool get darkMode => _preferences['darkMode'] as bool? ?? false;
  bool get notifications => _preferences['notifications'] as bool? ?? true;
  bool get journeyReminders =>
      _preferences['journeyReminders'] as bool? ?? true;
  Future<void> setPreference(String key, bool value) =>
      repository.user(uid).update({'preferences.$key': value});

  TrustedContact? get primaryContact {
    for (final contact in contacts) {
      if (contact.id == profile?.primaryContactId) return contact;
    }
    return null;
  }

  Destination? get selectedDestination {
    for (final destination in destinations) {
      if (destination.id == selectedDestinationId) return destination;
    }
    return destinations.isEmpty ? null : destinations.first;
  }

  String get displayName =>
      profile?.name.isNotEmpty == true ? profile!.name : auth.displayName;
  String get uid => _uid ?? (throw StateError('Inicia sesión para continuar.'));

  void _emit() {
    if (!_disposed) notifyListeners();
  }

  void _authChanged() {
    if (_uid == auth.user?.uid && _generation > 0) return;
    unawaited(_connect());
  }

  Future<void> _connect() async {
    final generation = ++_generation;
    for (final subscription in _subscriptions) {
      unawaited(subscription.cancel());
    }
    _subscriptions.clear();
    final account = auth.user;
    _uid = account?.uid;
    profile = null;
    contacts = [];
    destinations = [];
    completedWalks = 0;
    selectedDestinationId = null;
    _preferences = {};
    error = null;
    loading = account != null;
    _emit();
    if (account == null) return;
    try {
      await repository.ensureUser(account).timeout(const Duration(seconds: 20));
      if (_disposed || generation != _generation) return;
      final ref = repository.user(account.uid);
      var pending = 4;
      final loaded = <String>{};
      final failedStreams = <String>{};
      void ready(String key) {
        if (loaded.add(key)) pending--;
        failedStreams.remove(key);
        loading = pending > 0 && failedStreams.isEmpty;
        if (failedStreams.isEmpty) error = null;
        _emit();
      }

      void failed(String key, Object cause) {
        if (_disposed || generation != _generation) return;
        failedStreams.add(key);
        error = 'No se pudieron cargar tus datos. Comprueba la conexión y vuelve a intentar.';
        loading = false;
        _emit();
      }

      void listen<T>(String key, Stream<T> stream, void Function(T) apply) {
        _subscriptions.add(
          stream.listen((value) {
            if (_disposed || generation != _generation) return;
            apply(value);
            ready(key);
          }, onError: (Object cause) => failed(key, cause)),
        );
      }

      listen('profile', ref.snapshots(), (snapshot) {
        profile = snapshot.exists
            ? UserProfile.fromMap(snapshot.data()!)
            : null;
        _preferences = Map<String, dynamic>.from(
          snapshot.data()?['preferences'] as Map? ?? {},
        );
      });
      listen('contacts', ref.collection('contacts').snapshots(), (snapshot) {
        contacts =
            snapshot.docs
                .map((doc) => TrustedContact.fromMap(doc.id, doc.data()))
                .toList()
              ..sort(
                (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
              );
      });
      listen('destinations', ref.collection('destinations').snapshots(), (
        snapshot,
      ) {
        destinations =
            snapshot.docs
                .map((doc) => Destination.fromMap(doc.id, doc.data()))
                .toList()
              ..sort((a, b) => a.title.compareTo(b.title));
      });
      listen('trips', ref.collection('trips').snapshots(), (snapshot) {
        completedWalks = snapshot.docs
            .where((doc) => doc.data()['status'] == 'completed')
            .length;
      });
    } catch (_) {
      if (_disposed || generation != _generation) return;
      error = 'No se pudo preparar tu perfil en Firebase. Vuelve a intentar.';
      loading = false;
      _emit();
    }
  }

  Future<void> retry() => _connect();
  Future<void> refresh() async {
    final generation = _generation;
    final ref = repository.user(uid);
    final results = await Future.wait([
      ref.get(const GetOptions(source: Source.server)),
      ref.collection('contacts').get(const GetOptions(source: Source.server)),
      ref
          .collection('destinations')
          .get(const GetOptions(source: Source.server)),
      ref.collection('trips').get(const GetOptions(source: Source.server)),
    ]);
    if (_disposed || generation != _generation) return;
    final user = results[0] as DocumentSnapshot<Map<String, dynamic>>;
    profile = user.exists ? UserProfile.fromMap(user.data()!) : null;
    _preferences = Map<String, dynamic>.from(
      user.data()?['preferences'] as Map? ?? {},
    );
    contacts =
        (results[1] as QuerySnapshot<Map<String, dynamic>>).docs
            .map((d) => TrustedContact.fromMap(d.id, d.data()))
            .toList()
          ..sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
          );
    destinations =
        (results[2] as QuerySnapshot<Map<String, dynamic>>).docs
            .map((d) => Destination.fromMap(d.id, d.data()))
            .toList()
          ..sort((a, b) => a.title.compareTo(b.title));
    completedWalks = (results[3] as QuerySnapshot<Map<String, dynamic>>).docs
        .where((d) => d.data()['status'] == 'completed')
        .length;
    error = null;
    _emit();
  }

  Future<void> saveProfile(String name, String phone, String city) {
    if (name.trim().isEmpty ||
        name.trim().length > 100 ||
        phone.trim().length > 25 ||
        city.trim().length > 100) {
      throw ArgumentError('Revisa el nombre, teléfono y ciudad.');
    }
    return repository.saveProfile(uid, name, phone, city);
  }

  Future<void> saveContact(TrustedContact contact) {
    if (contact.name.trim().isEmpty ||
        contact.name.trim().length > 100 ||
        contact.relationship.trim().length > 100 ||
        contact.relationship.trim().isEmpty ||
        !RegExp(r'^[+0-9 ()-]{7,25}$').hasMatch(contact.phone.trim())) {
      throw ArgumentError('Revisa los datos del contacto.');
    }
    return repository.saveContact(uid, contact);
  }

  Future<void> deleteContact(String id) => repository.deleteContact(uid, id);
  Future<void> setPrimary(String id) => repository.setPrimary(uid, id);
  Future<void> addDestination(
    String title,
    String address, {
    double? lat,
    double? lng,
  }) {
    if (title.trim().isEmpty ||
        title.trim().length > 100 ||
        address.trim().isEmpty ||
        address.trim().length > 300) {
      throw ArgumentError('Escribe el nombre y dirección del destino.');
    }
    return repository.addDestination(uid, title, address, lat: lat, lng: lng);
  }

  void selectDestination(String id) {
    selectedDestinationId = id;
    _emit();
  }

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    auth.removeListener(_authChanged);
    for (final subscription in _subscriptions) {
      unawaited(subscription.cancel());
    }
    super.dispose();
  }
}
