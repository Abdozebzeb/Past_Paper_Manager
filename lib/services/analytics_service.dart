import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'log_service.dart';
import '../logic/log_model.dart';

class AnalyticsService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<String?> getStoredUserId() async {
    return await LogService.getPref('user_id');
  }

  Future<void> initializeUser() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String cleanId = (user.email ?? "unknown").replaceAll('.', '_');
    await LogService.setPref('user_id', cleanId);

    String deviceType = Platform.isWindows ? "Windows" : (Platform.isMacOS ? "MacOS" : "Unknown");
    final userDocRef = _db.collection('users').doc(cleanId);

    // Initial check/create user doc
    final docSnapshot = await userDocRef.get();
    
    await userDocRef.set({
      'name': user.displayName ?? "No Name",
      'email': user.email ?? "No Email",
      'Device': deviceType,
      'whoami': Platform.environment['USERNAME'] ?? "Unknown",
      'hostname': Platform.localHostname,
      'lastSeen': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    if (!docSnapshot.exists || docSnapshot.data()?['createdAt'] == null) {
      await userDocRef.set({
        'appOpens': 1,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } else {
      await userDocRef.update({'appOpens': FieldValue.increment(1)});
      
      // SYNC DOWN FROM CLOUD
      final data = docSnapshot.data()!;
      
      // 1. Save Name locally to SQLite
      if (data['name'] != null) {
        await LogService.setPref('user_name', data['name']);
      }

      // 2. Download PaperLogs from Firebase to Local SQLite
      if (data['PaperLogs'] != null) {
        List<dynamic> cloudLogsRaw = data['PaperLogs'];
        List<PaperLog> cloudLogs = cloudLogsRaw
            .map((item) => PaperLog.fromMap(Map<String, dynamic>.from(item)))
            .toList();
        await LogService.bulkInsertLogs(cloudLogs);
      }
    }
  }

  Future<void> logButtonClick(String buttonName) async {
    try {
      final String? userId = await getStoredUserId();
      if (userId == null) return;
      await _db.collection('users').doc(userId).set({
        'buttonClicks': {buttonName: FieldValue.increment(1)},
        'lastSeen': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Error logging button click: $e");
    }
  }

  Future<void> logPaperOpen(String fileName) async {
    try {
      final String? userId = await getStoredUserId();
      if (userId == null) return;
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

  Future<void> logBatchDownloads(String userId, int count) async {
    try {
      final String idToUse = userId.isNotEmpty ? userId : (await getStoredUserId() ?? '');
      if (idToUse.isEmpty) return;
      await _db.collection('users').doc(idToUse).set({
        'totalFilesDownloaded': FieldValue.increment(count),
        'lastSeen': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Error logging download: $e");
    }
  }
}