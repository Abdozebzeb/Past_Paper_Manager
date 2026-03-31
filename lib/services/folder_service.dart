import 'dart:io';

class FolderService {
  static void openFolder(String path) {
    Process.run('explorer', [path]);
  }
}