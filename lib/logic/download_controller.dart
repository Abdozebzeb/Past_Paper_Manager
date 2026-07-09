import 'package:flutter/material.dart';
import 'downloader.dart';

class DownloadController extends ChangeNotifier {
  double progress = 0;
  bool isDownloading = false;

  Future<void> runDownloads(List<DownloadJob> jobs) async {
    isDownloading = true;
    progress = 0;
    notifyListeners();

    await Downloader.downloadBatch(
      jobs: jobs,
      onProgress: (p) {
        progress = p;
        notifyListeners();
      },
      onSuccess: (file) {},
      onFail: (file) {},
    );

    isDownloading = false;
    notifyListeners();
  }
}