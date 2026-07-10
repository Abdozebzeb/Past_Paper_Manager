import 'package:flutter/material.dart';

class OpenedFile {
  final String name;
  final String path;
  OpenedFile(this.name, this.path);
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
    _mainMenuIndex = 2;
    // Check if already open
    int existingIndex = _openFiles.indexWhere((f) => f.path == path);
    if (existingIndex != -1) {
      _currentTabIndex = existingIndex;
    } else {
      _openFiles.add(OpenedFile(name, path));
      _currentTabIndex = _openFiles.length - 1;
      
    }
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