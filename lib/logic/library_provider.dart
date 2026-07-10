import 'package:flutter/material.dart';
import 'paper_model.dart';
import 'file_scanner.dart';
import '../services/folder_service.dart';

class LibraryProvider extends ChangeNotifier {
  List<Paper> papers = [];
  String folderPath = "";

  
  String? subject, series, year, type, paper;

  Future<void> refreshFiles() async {
    folderPath = await FolderService.getPastPapersPath();
    papers = FileScanner.scan(folderPath);
    notifyListeners();
  }

  void setSelection({String? sub, String? ser, String? yr, String? ty, String? p}) {
    if (sub != null) subject = sub;
    if (ser != null) series = ser;
    if (yr != null) year = yr;
    if (ty != null) type = ty;
    if (p != null) paper = p;
    notifyListeners();
  }

  void clearSelectionsDownFrom(String level) {
    if (level == 'subject') { series = year = type = paper = null; }
    if (level == 'series') { year = type = paper = null; }
    if (level == 'year') { type = paper = null; }
    if (level == 'type') { paper = null; }
    notifyListeners();
  }
}