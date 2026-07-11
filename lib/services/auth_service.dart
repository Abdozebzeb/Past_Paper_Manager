import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart' as mobile;
import 'package:google_sign_in_all_platforms/google_sign_in_all_platforms.dart' as desktop;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> signInWithGoogle() async {
    try {
      
      if (!kIsWeb && (Platform.isWindows || Platform.isMacOS)) {
        
final googleSignIn = desktop.GoogleSignIn(
  params: desktop.GoogleSignInParams(
    clientId: "your_client_id",
    clientSecret: "your_client_secret", 
    redirectPort: 8080, 
  ),
);

        final response = await googleSignIn.signIn();
        if (response == null) return null;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: response.accessToken,
          idToken: response.idToken,
        );

        final UserCredential userCredential = await _auth.signInWithCredential(credential);
        return userCredential.user;
      } 
      
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
    await _auth.signOut();
  }
}