import 'package:flutter/material.dart';
import 'downloader.dart';

class DownloadController extends ChangeNotifier {
  double progress = 0;
  List<String> success = [];
  List<String> failed = [];
  bool isDownloading = false;

  Future<void> startDownload({
    required List<String> subjects, 
    required int startYear,
    required int endYear,
    required List<String> papers,
    required List<String> variants,
    required List<String> types,
  }) async {
    isDownloading = true;
    progress = 0;
    success.clear();
    failed.clear();
    notifyListeners();

    try {
      await Downloader.downloadPapers(
        subjects: subjects,
        startYear: startYear,
        endYear: endYear,
        papers: papers,
        variants: variants,
        types: types,
        onProgress: (p) {
          progress = p;
          notifyListeners();
        },
        onSuccess: (file) {
          success.add(file);
          notifyListeners();
        },
        onFail: (file) {
          failed.add(file);
          notifyListeners();
        },
      );
    } catch (e) {
      debugPrint("Download Error: $e");
    }

    isDownloading = false;
    notifyListeners();
  }
}

final downloadController = DownloadController();