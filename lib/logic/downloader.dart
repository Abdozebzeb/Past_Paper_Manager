import 'dart:io';
import 'package:http/http.dart' as http;
import '../services/folder_service.dart';
import '../services/config_service.dart';

class Downloader {
  static Future<void> downloadPapers({
    required List<String> subjects,
    required int startYear,
    required int endYear,
    required List<String> papers,
    required List<String> variants,
    required List<String> types,
    required Function(double) onProgress,
    required Function(String) onSuccess,
    required Function(String) onFail,
  }) async {
    final folderPath = await FolderService.getPastPapersPath();
    List<String> seriesList = ['s', 'w', 'm'];
    List<String> urlsToTry = [];

    
    for (String subject in subjects) {
      for (int year = startYear; year <= endYear; year++) {
        String yr = year.toString().padLeft(2, '0');
        for (String series in seriesList) {
          for (String type in types) {
            if (type == 'gt') {
              urlsToTry.add("${subject}_${series}${yr}_gt.pdf");
            } else {
              for (String p in papers) {
                for (String v in variants) {
                  if (series == 'm' && v != '2') continue;
                  urlsToTry.add("${subject}_${series}${yr}_${type}_${p}${v}.pdf");
                }
              }
            }
          }
        }
      }
    }

    int total = urlsToTry.length;
    int done = 0;

    for (String fileName in urlsToTry) {
      bool downloaded = false;
      
      
      for (String basePath in ConfigService.downloadPaths) {
        try {
          final response = await http.get(Uri.parse("$basePath$fileName"));
          if (response.statusCode == 200) {
            final file = File("$folderPath${Platform.pathSeparator}$fileName");
            await file.writeAsBytes(response.bodyBytes);
            onSuccess(fileName);
            downloaded = true;
            break; 
          }
        } catch (_) {}
      }

      if (!downloaded) onFail(fileName);
      
      done++;
      onProgress(done / total);
    }
  }
}