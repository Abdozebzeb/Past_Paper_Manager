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
    if (sub != null) {
      if (subject != sub) { subject = sub; series = year = type = paper = null; }
    }
    if (ser != null) {
      if (series != ser) { series = ser; year = type = paper = null; }
    }
    if (yr != null) {
      if (year != yr) { year = yr; type = paper = null; }
    }
    if (ty != null) {
      if (type != ty) { type = ty; paper = null; }
    }
    if (p != null) paper = p;
    notifyListeners();
  }
}