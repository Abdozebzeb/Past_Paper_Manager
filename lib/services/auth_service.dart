import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart' as google_mobile;
import 'package:google_sign_in_all_platforms/google_sign_in_all_platforms.dart' as google_desktop;
import 'log_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static final google_desktop.GoogleSignIn _desktopSignIn = google_desktop.GoogleSignIn(
    params: google_desktop.GoogleSignInParams(
      clientId: "your_client_id",
      clientSecret: "your_client_secret",
      redirectPort: 8080,
      scopes: ['email', 'profile'],
    ),
  );

  Future<User?> signInWithGoogle() async {
    try {
      // Step 1: Force sign out first to ensure we aren't using a stale session
      await signOut();

      if (Platform.isWindows) {
        final response = await _desktopSignIn.signIn();
        if (response == null) return null;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: response.accessToken,
          idToken: response.idToken,
        );
        final UserCredential userCredential = await _auth.signInWithCredential(credential);
        return userCredential.user;
      } else {
        final google_mobile.GoogleSignIn googleSignIn = google_mobile.GoogleSignIn();
        final google_mobile.GoogleSignInAccount? googleUser = await googleSignIn.signIn();
        if (googleUser == null) return null;

        final google_mobile.GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final UserCredential userCredential = await _auth.signInWithCredential(credential);
        return userCredential.user;
      }
    } catch (e) {
      debugPrint("Login Error: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      if (Platform.isWindows) {
        await _desktopSignIn.signOut();
      } else {
        await google_mobile.GoogleSignIn().signOut();
      }
      await _auth.signOut();
      
      // Step 2: Clear our SQLite preferences (Theme, UserId, etc.)
      await LogService.clearPrefs();
    } catch (e) {
      debugPrint("Sign out error: $e");
    }
  }
}