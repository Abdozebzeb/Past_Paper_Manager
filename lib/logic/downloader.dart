import 'dart:io';
import 'package:http/http.dart' as http;
import '../services/folder_service.dart';
import '../services/config_service.dart';

class DownloadJob {
  List<String> subjects; 
  int startYear;
  int endYear;
  List<String> papers;
  List<String> variants;
  List<String> types;

  DownloadJob({
    required this.subjects,
    required this.startYear,
    required this.endYear,
    required this.papers,
    required this.variants,
    required this.types,
  });
}

class Downloader {
  static Future<void> downloadBatch({
    required List<DownloadJob> jobs,
    required Function(double) onProgress,
    required Function(String) onSuccess,
    required Function(String) onFail,
  }) async {
    final folderPath = await FolderService.getPastPapersPath();
    List<String> seriesList = ['s', 'w', 'm'];
    List<String> allFilesToDownload = [];

    
    List<String> activePaths = ConfigService.downloadPaths;

    for (var job in jobs) {
      for (var sub in job.subjects) {
        if (sub.isEmpty) continue;
        for (int year = job.startYear; year <= job.endYear; year++) {
          String yr = year.toString().padLeft(2, '0');
          for (String series in seriesList) {
            for (String type in job.types) {
              if (type == 'gt') {
                allFilesToDownload.add("${sub}_${series}${yr}_gt.pdf");
              } else {
                for (String p in job.papers) {
                  for (String v in job.variants) {
                    if (series == 'm' && v != '2') continue;
                    allFilesToDownload.add("${sub}_${series}${yr}_${type}_$p$v.pdf");
                  }
                }
              }
            }
          }
        }
      }
    }

    int total = allFilesToDownload.length;
    if (total == 0) {
      onProgress(1.0);
      return;
    }
    int done = 0;

    for (String fileName in allFilesToDownload) {
      bool success = false;
      for (String basePath in activePaths) {
        try {
          final url = basePath.endsWith('/') ? "$basePath$fileName" : "$basePath/$fileName";
          final response = await http.get(Uri.parse(url));
          if (response.statusCode == 200) {
            final file = File("$folderPath${Platform.pathSeparator}$fileName");
            await file.writeAsBytes(response.bodyBytes);
            onSuccess(fileName);
            success = true;
            break; 
          }
        } catch (_) {}
      }
      if (!success) onFail(fileName);
      done++;
      onProgress(done / total);
    }
  }
}