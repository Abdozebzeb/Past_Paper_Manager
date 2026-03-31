import 'dart:io';
import 'paper_model.dart';

class FileScanner {
  static List<Paper> scan(String folderPath) {
    final dir = Directory(folderPath);

    if (!dir.existsSync()) return [];

    final files = dir.listSync();
    List<Paper> papers = [];

    for (var file in files) {
      if (file.path.endsWith('.pdf')) {
        final name = file.uri.pathSegments.last;

        final parts = name.replaceAll('.pdf', '').split('_');

        if (parts.length >= 3) {
          final subject = parts[0];
          final seriesYear = parts[1];
          final type = parts[2];

          final series = seriesYear[0];
          final year = seriesYear.substring(1);

          String? paper;
          if (parts.length > 3) {
            paper = parts[3];
          }

          papers.add(Paper(
            subject: subject,
            series: series,
            year: year,
            type: type,
            paper: paper,
            path: file.path,
          ));
        }
      }
    }

    return papers;
  }
}