import '../services/log_service.dart';

class AppState {
  static Future<bool> isFirstRun() async {
    final val = await LogService.getPref('firstRun');
    return val == null; // If null, it's the first run
  }

  static Future<void> setNotFirstRun() async {
    await LogService.setPref('firstRun', 'false');
  }
}