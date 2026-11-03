import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../data/home_data.dart';

const _googleServerClientId =
    '1019858631171-sljtknk8956vu76s3318ri846rclvnjh.apps.googleusercontent.com';

class UserProvider extends ChangeNotifier {
  UserProvider() {
    _user = _auth.currentUser;
    _subscription = _auth.userChanges().listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription<User?>? _subscription;
  User? _user;
  bool _googleReady = false;

  User? get user => _user;

  bool get isLoggedIn => _user != null;

  String get displayName {
    final name = _user?.displayName?.trim();
    if (name != null && name.isNotEmpty) return name;
    final email = _user?.email;
    if (email != null && email.isNotEmpty) return email.split('@').first;
    return userName;
  }

  Future<void> signIn({required String email, required String password}) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await credential.user?.updateDisplayName(name);
    await credential.user?.reload();
  }

  Future<bool> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn.instance;
    if (!_googleReady) {
      await googleSignIn.initialize(serverClientId: _googleServerClientId);
      _googleReady = true;
    }
    final GoogleSignInAccount account;
    try {
      account = await googleSignIn.authenticate();
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) return false;
      rethrow;
    }
    final credential = GoogleAuthProvider.credential(
      idToken: account.authentication.idToken,
    );
    await _auth.signInWithCredential(credential);
    return true;
  }

  Future<void> signOut() async {
    if (_googleReady) await GoogleSignIn.instance.signOut();
    await _auth.signOut();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
