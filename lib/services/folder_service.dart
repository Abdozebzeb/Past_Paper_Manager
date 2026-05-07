import 'dart:io';

class FolderService {
  static String getPastPapersPath() {
    // Use the LOCALAPPDATA environment variable to get 'C:\Users\<User>\AppData\Local'
    final localAppData = Platform.environment['LOCALAPPDATA'];

    // Construct the full path to your app's specific data folder
    final folder = Directory('$localAppData\\Past Paper Manager\\PastPapers');

    if (!folder.existsSync()) {
      folder.createSync(recursive: true);
    }

    return folder.path;
  }

  static void openFolder(String path) {
    Process.run('explorer', [path]);
  }
}
