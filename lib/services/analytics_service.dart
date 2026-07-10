import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AnalyticsService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<String?> getStoredUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  Future<void> initializeUser() async {
    final prefs = await SharedPreferences.getInstance();
    String? storedId = prefs.getString('user_id');

    String windowsUser = Platform.environment['USERNAME'] ?? "Unknown_User";
    String deviceName = Platform.localHostname;

    String idToUse = storedId ?? "${windowsUser}_${DateTime.now().millisecondsSinceEpoch}";
    if (storedId == null) await prefs.setString('user_id', idToUse);

    final userDocRef = _db.collection('users').doc(idToUse);
    final docSnapshot = await userDocRef.get();

    if (!docSnapshot.exists) {
      await userDocRef.set({
        'whoami': windowsUser,
        'device': deviceName,
        'createdAt': FieldValue.serverTimestamp(),
        'lastSeen': FieldValue.serverTimestamp(),
        'appOpens': 1,
        'totalFilesDownloaded': 0,
        'buttonClicks': {},
        'openedPapers': {},
      });
    } else {
      await userDocRef.update({
        'lastSeen': FieldValue.serverTimestamp(),
        'appOpens': FieldValue.increment(1),
      });
    }
  }

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
        'buttonClicks': {buttonName: FieldValue.increment(1)},
        'lastSeen': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Error logging button click: $e");
    }
  }

  Future<void> logPaperOpen(String userId, String fileName) async {
    try {
      String cleanName = fileName.replaceAll('.pdf', '').replaceAll('.', '_');
      String uniqueKey = "${cleanName}_${DateTime.now().millisecondsSinceEpoch}";

      await _db.collection('users').doc(userId).set({
        'openedPapers': {uniqueKey: FieldValue.serverTimestamp()},
        'lastSeen': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Error logging paper open: $e");
    }
  }
}