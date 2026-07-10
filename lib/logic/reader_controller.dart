import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class OpenedFile {
  final String name;
  final String path;
  double zoom;
  int currentPage;
  int totalPages;
  final PdfViewerController controller;

  OpenedFile({
    required this.name,
    required this.path,
    this.zoom = 0.8,
    this.currentPage = 1,
    this.totalPages = 0,
  }) : controller = PdfViewerController();
}

class ReaderController extends ChangeNotifier {
  int _mainMenuIndex = 0;
  int get mainMenuIndex => _mainMenuIndex;

  void setMenuIndex(int index) {
    _mainMenuIndex = index;
    notifyListeners();
  }

  final List<OpenedFile> _openFiles = [];
  int _currentTabIndex = 0;

  List<OpenedFile> get openFiles => _openFiles;
  int get currentTabIndex => _currentTabIndex;

  void openFile(String name, String path) {
    int existingIndex = _openFiles.indexWhere((f) => f.path == path);
    if (existingIndex != -1) {
      _currentTabIndex = existingIndex;
    } else {
      _openFiles.add(OpenedFile(name: name, path: path));
      _currentTabIndex = _openFiles.length - 1;
    }
    _mainMenuIndex = 2; // Automatically switch to Reader
    notifyListeners();
  }

  void updateZoom(int index, double newZoom) {
    _openFiles[index].zoom = newZoom.clamp(0.3, 5.0);
    // If zooming into the content, sync the PDF controller zoom
    if (_openFiles[index].zoom >= 1.0) {
      _openFiles[index].controller.zoomLevel = _openFiles[index].zoom;
    } else {
      _openFiles[index].controller.zoomLevel = 1.0;
    }
    notifyListeners();
  }

  void updatePageInfo(int index, int current, int total) {
    _openFiles[index].currentPage = current;
    if (total > 0) _openFiles[index].totalPages = total;
    notifyListeners();
  }

  void closeTab(int index) {
    _openFiles.removeAt(index);
    if (_currentTabIndex >= _openFiles.length) {
      _currentTabIndex = _openFiles.isEmpty ? 0 : _openFiles.length - 1;
    }
    notifyListeners();
  }

  void setTab(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }
}