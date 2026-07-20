import 'package:flutter/material.dart';
import '../services/log_service.dart';

class SettingsProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  ThemeMode get themeMode => _themeMode;

  SettingsProvider() {
    _loadTheme();
  }

  void _loadTheme() async {
    final theme = await LogService.getPref('theme') ?? 'dark';
    _themeMode = theme == 'light' ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  void toggleTheme(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    await LogService.setPref('theme', isDark ? 'dark' : 'light');
    notifyListeners();
  }
}