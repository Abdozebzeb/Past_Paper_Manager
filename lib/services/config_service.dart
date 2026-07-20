import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'log_service.dart';

class ConfigService {
  
  static List<String> downloadPaths = [
    "https://pastpapers.papacambridge.com/directories/CAIE/CAIE-pastpapers/upload/"
  ];

  // Added static variable for TimeTable.db dynamic download URL
  static String timeTableUrl = "https://abdozebzeb.github.io/CIE-Dates-Data/TimeTable.db";

  static Future<void> fetchRemoteConfig() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('settings').doc('config').get();
      
      if (doc.exists) {
        final data = doc.data()!;
        
        List<dynamic>? remotePaths = data['DownloadPath'] ?? data['urls'] ?? data['paths'];

        if (remotePaths != null && remotePaths.isNotEmpty) {
          downloadPaths = List<String>.from(remotePaths);
          debugPrint("Config: Successfully loaded ${downloadPaths.length} paths from Firebase.");
        } else {
          debugPrint("Config: Document found but no 'DownloadPath' field found. Using default.");
        }

        // Capture dynamic URL for TimeTable.db from Firestore if available
        if (data['DownLoadURLTimeTabledb'] != null) {
          timeTableUrl = data['DownLoadURLTimeTabledb'];
          debugPrint("Config: Loaded timeTableUrl: $timeTableUrl");
        }
        
        await LogService.setPref('data_version', (data['DataVersion'] ?? 1).toString());
      } else {
        debugPrint("Config: No document found at settings/config in Firestore.");
      }
    } catch (e) {
      debugPrint("Config Fetch Error: $e");
    }
  }
}