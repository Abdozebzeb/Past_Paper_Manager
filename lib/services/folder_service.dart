import 'dart:io';

class FolderService {
  static String getPastPapersPath() {
    
    final localAppData = Platform.environment['LOCALAPPDATA'];

    
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
