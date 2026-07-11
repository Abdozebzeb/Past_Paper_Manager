import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart' as mobile;
import 'package:google_sign_in_all_platforms/google_sign_in_all_platforms.dart' as desktop;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- FIX: Create the Desktop instance ONCE at the class level ---
  static final desktop.GoogleSignIn _desktopSignIn = desktop.GoogleSignIn(
    params: desktop.GoogleSignInParams(
    clientId: "775491767902-mgh96bqr9k1ac7md6lrfjqrj3ullrlkl.apps.googleusercontent.com",
    clientSecret: "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", // Windows needs this!
    redirectPort: 8080, // This is important

    scopes: ['email', 'profile'],
    ),
  );

  Future<User?> signInWithGoogle() async {
    try {
      // WINDOWS / MACOS LOGIC
      if (!kIsWeb && (Platform.isWindows || Platform.isMacOS)) {
        // Use the existing static instance instead of creating a new one
        final response = await _desktopSignIn.signIn();
        
        if (response == null) return null;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: response.accessToken,
          idToken: response.idToken,
        );

        final UserCredential userCredential = await _auth.signInWithCredential(credential);
        return userCredential.user;
      }

      // MOBILE LOGIC
      else {
        final mobile.GoogleSignIn googleSignIn = mobile.GoogleSignIn();
        final mobile.GoogleSignInAccount? googleUser = await googleSignIn.signIn();
        if (googleUser == null) return null;

        final mobile.GoogleSignInAuthentication googleAuth = await googleUser.authentication;
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
      await _auth.signOut();
      // Note: desktop_sign_in_all_platforms does not usually require 
      // a specific plugin signout call to clear the session locally.
    } catch (e) {
      debugPrint("Sign out error: $e");
    }
  }
}