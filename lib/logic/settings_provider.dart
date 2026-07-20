import 'package:flutter/material.dart';
import '../services/log_service.dart';
import '../services/accent_service.dart';

class SettingsProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  String _accentName = "Ocean Blue";

  ThemeMode get themeMode => _themeMode;
  String get accentName => _accentName;

  // This helper allows any widget to get the current colors easily
  AccentPalette get current => AccentService.getPalette(_accentName, _themeMode == ThemeMode.dark);

  SettingsProvider() {
    _loadSettings();
  }

  void _loadSettings() async {
    final theme = await LogService.getPref('theme') ?? 'dark';
    final accent = await LogService.getPref('accent_name') ?? 'Ocean Blue';
    
    _themeMode = theme == 'light' ? ThemeMode.light : ThemeMode.dark;
    _accentName = accent;
    notifyListeners();
  }

  void toggleTheme(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    await LogService.setPref('theme', isDark ? 'dark' : 'light');
    notifyListeners();
  }

  void setAccent(String name) async {
    _accentName = name;
    await LogService.setPref('accent_name', name);
    notifyListeners();
  }
}