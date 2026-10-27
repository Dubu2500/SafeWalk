import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'home_data.dart';

// Web client (client_type 3) from android/app/google-services.json.
const _googleServerClientId =
    '1019858631171-sljtknk8956vu76s3318ri846rclvnjh.apps.googleusercontent.com';

bool _googleReady = false;

// Uses the signed-in Firebase user; falls back to the demo name when
// Firebase is not initialized (widget tests) or the user has no name.
String currentUserName() {
  if (Firebase.apps.isEmpty) return userName;
  final user = FirebaseAuth.instance.currentUser;
  final name = user?.displayName?.trim();
  if (name != null && name.isNotEmpty) return name;
  final email = user?.email;
  if (email != null && email.isNotEmpty) return email.split('@').first;
  return userName;
}

// Opens the Google account picker and signs in to Firebase with that account.
// Returns false if the user closes the picker without choosing an account.
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
  await FirebaseAuth.instance.signInWithCredential(credential);
  return true;
}

Future<void> signOutCurrentUser() async {
  if (Firebase.apps.isEmpty) return;
  if (_googleReady) await GoogleSignIn.instance.signOut();
  await FirebaseAuth.instance.signOut();
}
