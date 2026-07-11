import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class ConfigService {
  // The default link is only used if Firebase is unreachable
  static List<String> downloadPaths = [
    "https://pastpapers.papacambridge.com/directories/CAIE/CAIE-pastpapers/upload/"
  ];

  static Future<void> fetchRemoteConfig() async {
    try {
      // Structure: Collection 'settings' -> Document 'config'
      final doc = await FirebaseFirestore.instance.collection('settings').doc('config').get();
      
      if (doc.exists) {
        final data = doc.data()!;
        
        // Check for 'DownloadPath' or 'urls' or 'paths' (lenient naming)
        List<dynamic>? remotePaths = data['DownloadPath'] ?? data['urls'] ?? data['paths'];

        if (remotePaths != null && remotePaths.isNotEmpty) {
          // IMPORTANT: We replace the list entirely so the hardcoded one is GONE
          downloadPaths = List<String>.from(remotePaths);
          debugPrint("Config: Successfully loaded ${downloadPaths.length} paths from Firebase.");
        } else {
          debugPrint("Config: Document found but no 'DownloadPath' field found. Using default.");
        }
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('data_version', data['DataVersion'] ?? 1);
      } else {
        debugPrint("Config: No document found at settings/config in Firestore.");
      }
    } catch (e) {
      debugPrint("Config Fetch Error: $e");
    }
  }
}