import 'dart:io';

class FileOpenService {
  static void openFile(String path) {
    Process.run('cmd', ['/c', 'start', '', path]);
  }
}