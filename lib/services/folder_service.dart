import 'dart:io';

class FolderService {
  static String getPastPapersPath() {
    final exeDir = File(Platform.resolvedExecutable).parent;
    final folder = Directory('${exeDir.path}\\PastPapers');

    if (!folder.existsSync()) {
      folder.createSync(recursive: true);
    }

    return folder.path;
  }

  static void openFolder(String path) {
    Process.run('explorer', [path]);
  }
}