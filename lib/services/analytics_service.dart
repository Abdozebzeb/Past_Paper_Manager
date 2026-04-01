import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // For debugPrint

class AnalyticsService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Helper to get the saved ID from Windows storage
  Future<String?> getStoredUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  Future<void> initializeUser() async {
    final prefs = await SharedPreferences.getInstance();
    String? storedId = prefs.getString('user_id');

    String windowsUser = Platform.environment['USERNAME'] ?? "Unknown_User";
    String deviceName = Platform.localHostname;

    // Use existing ID or create new one
    String idToUse = storedId ?? "${windowsUser}_${DateTime.now().millisecondsSinceEpoch}";
    
    if (storedId == null) {
      await prefs.setString('user_id', idToUse);
    }

    // UPDATED: Use .set with merge: true to ensure the document exists
    await _db.collection('users').doc(idToUse).set({
      'whoami': windowsUser,
      'device': deviceName,
      'lastSeen': FieldValue.serverTimestamp(),
      'appOpens': FieldValue.increment(1),
      // createdAt is only set if the document doesn't exist yet
      'createdAt': FieldValue.serverTimestamp(), 
    }, SetOptions(merge: true));
  }

  // UPDATED: Set with merge prevents "Document Not Found" exceptions
  Future<void> logBatchDownloads(String userId, int count) async {
    try {
      await _db.collection('users').doc(userId).set({
        'totalFilesDownloaded': FieldValue.increment(count),
        'lastSeen': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Error logging batch download: $e");
    }
  }

  Future<void> logButtonClick(String buttonName, String userId) async {
    try {
      await _db.collection('users').doc(userId).set({
        'buttonClicks': {
          buttonName: FieldValue.increment(1),
        },
        'lastSeen': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Error logging button click: $e");
    }
  }
}