import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfigService {
  static List<String> downloadPaths = [
    "https://pastpapers.papacambridge.com/directories/CAIE/CAIE-pastpapers/upload/"
  ];

  static Future<void> fetchRemoteConfig() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('settings').doc('config').get();
      if (doc.exists) {
        final data = doc.data()!;
        final paths = List<String>.from(data['DownloadPath'] ?? []);
        if (paths.isNotEmpty) {
          downloadPaths = paths;
        }
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('data_version', data['DataVersion'] ?? 1);
      }
    } catch (e) {
      print("Config Fetch Error: $e");
    }
  }
}