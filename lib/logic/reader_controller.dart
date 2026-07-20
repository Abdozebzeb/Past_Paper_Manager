import 'dart:async';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class FilePanelState {
  String paperName = "Loading...";
  String paperCode = "Loading...";
  String duration = "0 minutes";
  String rawMarks = "-";
  Map<String, String> thresholds = {'A': '-', 'B': '-', 'C': '-', 'D': '-', 'E': '-'};
  
  int timerSeconds = 0;
  int stopwatchSeconds = 0;
  bool isTimer = true;
  bool isRunning = false;
  String scoredMarksInput = "";
  bool isDataLoaded = false;
}

class OpenedFile {
  final String name;
  final String path;
  double zoom;
  int currentPage;
  int totalPages;
  final PdfViewerController controller;
  final FilePanelState panelState; // Side panel data preserved here

  OpenedFile({
    required this.name,
    required this.path,
    this.zoom = 0.8,
    this.currentPage = 1,
    this.totalPages = 0,
  }) : controller = PdfViewerController(),
       panelState = FilePanelState();
}

class ReaderController extends ChangeNotifier {
  int _mainMenuIndex = 0;
  int get mainMenuIndex => _mainMenuIndex;

  Timer? _globalTicker;

  ReaderController() {
    _startGlobalTicker();
  }

  void _startGlobalTicker() {
    _globalTicker = Timer.periodic(const Duration(seconds: 1), (timer) {
      bool changed = false;
      for (var file in _openFiles) {
        if (file.panelState.isRunning) {
          if (file.panelState.isTimer) {
            if (file.panelState.timerSeconds > 0) {
              file.panelState.timerSeconds--;
              changed = true;
            } else {
              file.panelState.isRunning = false;
              changed = true;
            }
          } else {
            file.panelState.stopwatchSeconds++;
            changed = true;
          }
        }
      }
      if (changed) notifyListeners();
    });
  }

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
    _mainMenuIndex = 2; 
    notifyListeners();
  }

  void updateZoom(int index, double newZoom) {
    _openFiles[index].zoom = newZoom.clamp(0.3, 5.0);
    _openFiles[index].controller.zoomLevel = _openFiles[index].zoom >= 1.0 ? _openFiles[index].zoom : 1.0;
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

  @override
  void dispose() {
    _globalTicker?.cancel();
    super.dispose();
  }
}