import 'package:flutter/material.dart';
import 'paper_model.dart';
import 'file_scanner.dart';
import '../services/folder_service.dart';

class LibraryProvider extends ChangeNotifier {
  List<Paper> papers = [];
  String folderPath = "";

  // Selection State (Moved here to persist across page changes)
  String? subject, series, year, type, paper;

  Future<void> refreshFiles() async {
    folderPath = await FolderService.getPastPapersPath();
    papers = FileScanner.scan(folderPath);
    notifyListeners();
  }

  void setSelection({String? sub, String? ser, String? yr, String? ty, String? p}) {
    // Logic to clear lower levels if a higher level changes
    if (sub != null && sub != subject) {
      subject = sub;
      series = year = type = paper = null;
    } else if (ser != null && ser != series) {
      series = ser;
      year = type = paper = null;
    } else if (yr != null && yr != year) {
      year = yr;
      type = paper = null;
    } else if (ty != null && ty != type) {
      type = ty;
      paper = null;
    } else if (p != null) {
      paper = p;
    }
    notifyListeners();
  }

  void clearAll() {
    subject = series = year = type = paper = null;
    notifyListeners();
  }
}