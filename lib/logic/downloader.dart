import 'dart:io';
import 'package:http/http.dart' as http;
import '../services/folder_service.dart';

class Downloader {
  static Future<void> downloadPapers({
    required String subject,
    required int startYear,
    required int endYear,
    required List<String> papers,
    required List<String> variants,
    required List<String> types,
    required Function(double) onProgress,
    required Function(String) onSuccess,
    required Function(String) onFail,
  }) async {
    final folderPath = FolderService.getPastPapersPath();

    List<String> urls = [];

    List<String> seriesList = ['s', 'w', 'm'];

    // ================= GENERATE LINKS =================
    for (int year = startYear; year <= endYear; year++) {
      String yearStr = year.toString().padLeft(2, '0');

      for (String series in seriesList) {
        for (String type in types) {
          if (type == 'gt') {
            urls.add(
                "https://pastpapers.papacambridge.com/directories/CAIE/CAIE-pastpapers/upload/${subject}_${series}${yearStr}_gt.pdf");
          } else {
            for (String p in papers) {
              for (String v in variants) {
                if (series == 'm' && v != '2') continue;

                urls.add(
                    "https://pastpapers.papacambridge.com/directories/CAIE/CAIE-pastpapers/upload/${subject}_${series}${yearStr}_${type}_${p}${v}.pdf");
              }
            }
          }
        }
      }
    }

    int total = urls.length;
    int done = 0;

    // ================= DOWNLOAD =================
    for (String url in urls) {
      try {
        final filename = url.split('/').last;
        final filePath = "$folderPath\\$filename";

        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          File(filePath).writeAsBytesSync(response.bodyBytes);
          onSuccess(filename);
        } else {
          onFail(filename);
        }
      } catch (e) {
        final filename = url.split('/').last;
        onFail(filename);
      }

      done++;
      onProgress(done / total);
    }
  }
}