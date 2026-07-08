import 'dart:io';
import 'package:http/http.dart' as http;
import '../services/folder_service.dart';
import '../services/config_service.dart';

class DownloadJob {
  String subject;
  int startYear;
  int endYear;
  List<String> papers;
  List<String> variants;
  List<String> types;

  DownloadJob({
    required this.subject,
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
    List<String> allUrls = [];

    
    for (var job in jobs) {
      for (int year = job.startYear; year <= job.endYear; year++) {
        String yr = year.toString().padLeft(2, '0');
        for (String series in seriesList) {
          for (String type in job.types) {
            if (type == 'gt') {
              allUrls.add("${job.subject}_${series}${yr}_gt.pdf");
            } else {
              for (String p in job.papers) {
                for (String v in job.variants) {
                  if (series == 'm' && v != '2') continue;
                  allUrls.add("${job.subject}_${series}${yr}_${type}_$p$v.pdf");
                }
              }
            }
          }
        }
      }
    }

    int total = allUrls.length;
    if (total == 0) return;
    int done = 0;

    for (String fileName in allUrls) {
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