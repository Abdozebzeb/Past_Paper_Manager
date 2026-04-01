import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

    if (storedId == null) {
      String newId = "${windowsUser}_${DateTime.now().millisecondsSinceEpoch}";
      await prefs.setString('user_id', newId);

      await _db.collection('users').doc(newId).set({
        'whoami': windowsUser,
        'device': deviceName,
        'createdAt': FieldValue.serverTimestamp(),
        'totalFilesDownloaded': 0, // Changed from downloads to reflect your UI
        'appOpens': 1,
        'buttonClicks': {}, // Placeholder for various button tracking
        'lastSeen': FieldValue.serverTimestamp(),
      });
    } else {
      await _db.collection('users').doc(storedId).update({
        'appOpens': FieldValue.increment(1),
        'lastSeen': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> logBatchDownloads(String userId, int count) async {
    try {
      await _db.collection('users').doc(userId).update({
        'totalFilesDownloaded': FieldValue.increment(count),
      });
    } catch (e) {
      // Use delegate to print to console without crashing
      print("Error logging batch download: $e");
    }
  }
  // New Method: Track specific button clicks (like 'sidebar_about', etc.)
  Future<void> logButtonClick(String buttonName, String userId) async {
    await _db.collection('users').doc(userId).update({
      'buttonClicks.$buttonName': FieldValue.increment(1),
    });
  }

  // New Method: Track every time a PDF is successfully opened
  Future<void> logPaperOpened(String userId) async {
    await _db.collection('users').doc(userId).update({
      'totalFilesDownloaded': FieldValue.increment(1),
    });
  }
}