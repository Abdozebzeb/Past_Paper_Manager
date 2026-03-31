import 'package:shared_preferences/shared_preferences.dart';

class AppState {
  static Future<bool> isFirstRun() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('firstRun') ?? true;
  }

  static Future<void> setNotFirstRun() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('firstRun', false);
  }
}